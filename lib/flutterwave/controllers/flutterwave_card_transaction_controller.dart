import 'dart:convert';

import 'package:kite_bird/accounts/models/accounts_models.dart';
import 'package:kite_bird/cooprates/utils/cooprates_utils.dart' show getCooprateCodeByAccoutId;
import 'package:kite_bird/flutterwave/modules/flutterwave_modules.dart' show FlutterWaveCardDeposit;
import 'package:kite_bird/flutterwave/requests/flutterwave_requests_manager.dart';
import 'package:kite_bird/flutterwave/serializers/flutterwave_serializers.dart' show FlutterwaveCardSerializer;
import 'package:kite_bird/kite_bird.dart';
import 'package:kite_bird/response/models/response_models.dart';
import 'package:kite_bird/wallets/models/wallets_models.dart' show WalletModel;

class FlutterWaveCardTransactionController extends ResourceController{
  final AccountModel accountModel = AccountModel();

  String _requestId;
  final ResposeType _responseType = ResposeType.card;
  ResponsesStatus _responseStatus;
  dynamic _responseBody;

  @Operation.post()
  Future<Response> card(
    @Bind.body(require: ['cardNo', 'cvv', 'expiryMonth', 'expiryYear', 'amount', 'email', 'walletNo', 'callbackUrl'])
    FlutterwaveCardSerializer flutterwaveCardSerializer
    )async{
    final Map<String, dynamic> _dbResAcc =await accountModel.findById(request.authorization.clientID, fields: ['phoneNo']);
    String _phoneNo;
    if(_dbResAcc['status'] == 0){
      _phoneNo  = _dbResAcc['body']['phoneNo'].toString();
    }
      // save request
    final FlutterwaveRequests _flutterwaveRequests = FlutterwaveRequests(
      account: _phoneNo,
      metadata: {
        'amount': flutterwaveCardSerializer.amount,
        'cardNo': flutterwaveCardSerializer.cardNo,
        'email': flutterwaveCardSerializer.email,
        'currency': 'KES',
        'country': 'KE',
        'walletNo': flutterwaveCardSerializer.walletNo,
        'callbackUrl': flutterwaveCardSerializer.callbackUrl 
      }
    );
    _flutterwaveRequests.normalRequest();
    _requestId = _flutterwaveRequests.requestId();
    // check if wallet exist
    final WalletModel walletModel = WalletModel();
    final bool walletExist =await walletModel.exists(where.eq('walletNo', flutterwaveCardSerializer.walletNo));
    if(!walletExist){
      _responseStatus = ResponsesStatus.failed;
      _responseBody = {"body": "Recipient Account does not exist"};
    } else{

      // get cooprate code
      final String cooprateCode = await getCooprateCodeByAccoutId(request.authorization.clientID);


      // transact
      final FlutterWaveCardDeposit _flutterWaveCardDeposit = FlutterWaveCardDeposit(
        cooprateCode: cooprateCode,
        amount: flutterwaveCardSerializer.amount,
        callbackUrl: flutterwaveCardSerializer.callbackUrl,
        cardNo: flutterwaveCardSerializer.cardNo,
        cvv: flutterwaveCardSerializer.cvv,
        email: flutterwaveCardSerializer.email,
        expiryMonth: flutterwaveCardSerializer.expiryMonth,
        expiryYear: flutterwaveCardSerializer.expiryYear,
        // walletNo: flutterwaveCardSerializer.walletNo,
        requestId: _requestId
      );
      final Map<String, dynamic> _cardRes = await _flutterWaveCardDeposit.flutterWaveCardTransact();

      // compute response
      if(_cardRes['status'] != 0){
        _responseStatus = ResponsesStatus.error;
        _responseBody = {'body': 'An error occured!'};
      } else {
        dynamic _mpesaResponseBody;
        final int _mpesaResponseStatusCode = int.parse(_cardRes['body'].statusCode.toString());
        
        try {
          _mpesaResponseBody = json.decode(_cardRes['body'].body.toString());
          _mpesaResponseBody['requestId'] = _requestId;
        } catch (e) {
          _mpesaResponseBody = _cardRes['body'].body; 
        }
        _responseBody = {'body': _mpesaResponseBody};

        switch (_mpesaResponseStatusCode) {
          case 200:
            _responseStatus = ResponsesStatus.success;
            break;
          case 400:
            _responseStatus = ResponsesStatus.failed;
            break;
          case 500:
            _responseStatus = ResponsesStatus.warning;
            break;
          default:
          _responseStatus = ResponsesStatus.notDefined;
        }
      } 
    }
    // save response
    final ResponsesModel _responsesModel = ResponsesModel(
      requestId: _requestId,
      responseType: _responseType,
      responseBody: _responseBody,
      status: _responseStatus
    );

    await _responsesModel.save();

    return _responsesModel.sendResponse();

  }
}
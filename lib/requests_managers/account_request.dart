import 'package:kite_bird/models/requests_model.dart';
import 'package:pedantic/pedantic.dart';

class AccountRequest{
  AccountRequest({this.account, this.accountRequestsType, this.metadata});


  final String account;
  final dynamic metadata;
  final AccountRequestsType accountRequestsType;

  ObjectId id = ObjectId();
  String _url = '/account';
  String requestId() => id.toJson();
  RequestMethod _requestMethod = RequestMethod.getmethod;
  final RequestType _requestType = RequestType.account;

    void normalRequest()async{
    switch (accountRequestsType) {
      case AccountRequestsType.register:
        _requestMethod = RequestMethod.postMethod;
        break;
      case AccountRequestsType.delete:
        _requestMethod = RequestMethod.deleteMethod;
        _url = '/account/:accountId';
        break;
      case AccountRequestsType.getAll:
        _requestMethod = RequestMethod.getmethod;
        break;
        case AccountRequestsType.getByPhoneNo:
        _requestMethod = RequestMethod.getmethod;
        _url = '/account/phoneNo/:phoneNo';
        break;
      case AccountRequestsType.getByid:
        _requestMethod = RequestMethod.getmethod;
        _url = '/account/:accountId';
        break;
       case AccountRequestsType.login:
        _requestMethod = RequestMethod.getmethod;
        _url = '/account/login';
        break;
      default:
    }

    final RequestsModel _requestsModel = RequestsModel(
      id: id,
      url: _url,
      requestType: _requestType,
      requestMethod: _requestMethod,
      account: account,
      metadata: metadata
    );
    unawaited(_requestsModel.save());
  }


}

enum AccountRequestsType{
  delete,
  getAll,
  getByid,
  getByPhoneNo,
  login,
  register,
  verifyOtp,
  verifyPhoneNo,
}
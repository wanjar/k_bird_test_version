import 'package:kite_bird/requests/models/requests_models.dart' show 
        ObjectId, RequestMethod, RequestsModel, RequestType;

class CooperateRequest{
  CooperateRequest({this.account, this.metadata, this.cooperateRequestsType});

  final String account;
  final dynamic metadata;
  final CooperateRequestsType cooperateRequestsType;

  ObjectId id = ObjectId();
  String _url = '/cooperate';
  String requestId() => id.toJson();
  RequestMethod _requestMethod = RequestMethod.getmethod;
  final RequestType _requestType = RequestType.cooperate;

  void normalRequest()async{
    switch (cooperateRequestsType) {
      case CooperateRequestsType.create:
        _requestMethod = RequestMethod.postMethod;
        break;
      case CooperateRequestsType.createSettings:
        _requestMethod = RequestMethod.postMethod;
        _url = '/cooperate/settings/...';
        break;
      case CooperateRequestsType.updateSettings:
        _requestMethod = RequestMethod.putMethod;
        _url = '/cooperate/settings/...';
        break;
      case CooperateRequestsType.transaction:
        _requestMethod = RequestMethod.postMethod;
        _url = '/cooperate/transaction/...';
        break;
      
      case CooperateRequestsType.delete:
        _requestMethod = RequestMethod.deleteMethod;
        _url = '/cooperate/:cooperateId';
        break;
      case CooperateRequestsType.getAll:
        _requestMethod = RequestMethod.getmethod;
        break;
        case CooperateRequestsType.getByName:
        _requestMethod = RequestMethod.getmethod;
        _url = '/cooperate/name/:cooperateName';
        break;
        case CooperateRequestsType.getByCooprateCode:
        _requestMethod = RequestMethod.getmethod;
        _url = '/cooperate/code/:cooperateCode';
        break;
      case CooperateRequestsType.getByid:
        _requestMethod = RequestMethod.getmethod;
        _url = '/cooperate/:cooperateId';
        break;
       case CooperateRequestsType.token:
        _requestMethod = RequestMethod.getmethod;
        _url = '/cooperate/token';
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
    await _requestsModel.save();
  }

  // token
}
enum CooperateRequestsType{
  create,
  createSettings,
  updateSettings,
  transaction,
  getAll,
  getByid,
  getByName,
  getByCooprateCode,
  delete,
  token
}
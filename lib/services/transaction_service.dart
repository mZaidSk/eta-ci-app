import '../models/transaction.dart';
import 'crud_service.dart';

class TransactionService extends CrudService<Transaction> {
  TransactionService() : super(endpoint: '/transactions/trans/');
}

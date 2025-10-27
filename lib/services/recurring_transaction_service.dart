import '../models/recurring_transaction.dart';
import 'crud_service.dart';

class RecurringTransactionService extends CrudService<RecurringTransaction> {
  RecurringTransactionService() : super(endpoint: '/transactions/recurring/');
}

import '../data/models/order_model.dart';

sealed class OrdersState {
  const OrdersState();
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  const OrdersLoaded(this.orders);
}

final class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
}

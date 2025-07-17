import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/providers/restaurant_provider.dart'; // Import provider
import 'package:provider/provider.dart'; // Import provider
import 'package:foodapp/models/restaurant_data.dart'; // Import Order model

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors1.circleAvatarBackGrey,
            child: IconButton(
              onPressed: () {
                // If there's a page to pop back to, do it.
                // Otherwise, go to the home page as a fallback.
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            ),
          ),
        ),
        title: Text('My Orders', style: GoogleFonts.sen(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTab('Ongoing', 0),
                _buildTab('History', 1),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RestaurantProvider>(
                builder: (context, restaurantProvider, child) {
                  final allOrders = restaurantProvider.orders;
                  final filteredOrders = _selectedTab == 0
                      ? allOrders.where((order) => order.status == OrderStatus.ongoing).toList()
                      : allOrders.where((order) => order.status != OrderStatus.ongoing).toList(); // History includes completed/cancelled

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Text(
                        _selectedTab == 0 ? 'No ongoing orders.' : 'No past orders.',
                        style: GoogleFonts.sen(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: OrderCard(
                          order: order,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: _selectedTab == index ? Colors1.primaryOrange : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.sen(
            fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedTab == index ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    super.key,
    required this.order,
  });

  // Helper to get a display name for the order type
  String get _orderType {
    if (order.items.isNotEmpty) {
      return order.items.first.key.category;
    }
    return 'Mixed Items'; // Fallback if no items or mixed categories
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _orderType,
                  style: GoogleFonts.sen(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${order.vendor}    ${order.orderId}',
                  style: GoogleFonts.sen(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.sen(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${order.totalItems} Items',
                  style: GoogleFonts.sen(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Display status
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: GoogleFonts.sen(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildActionButtons(context, order),
          ],
        ),
      ),
    );
  }

  /// Conditionally builds the action buttons based on the order's status.
  Widget _buildActionButtons(BuildContext context, Order order) {
    final provider = context.read<RestaurantProvider>();

    if (order.status == OrderStatus.ongoing) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tracking order ${order.orderId}...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors1.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('Track Order', style: GoogleFonts.sen(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                provider.cancelOrder(order);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order ${order.orderId} has been cancelled.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('Cancel', style: GoogleFonts.sen(color: Colors.black)),
            ),
          ),
        ],
      );
    } else {
      // For Completed or Cancelled orders, show a "Reorder" button
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                provider.reorder(order);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Items from order ${order.orderId} added to cart.'),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      textColor: Colors1.lightyellow,
                      onPressed: () => context.push(AppRoutes.cart),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors1.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('Reorder', style: GoogleFonts.sen(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Navigate to the Order Details page, passing the order object
                context.push(AppRoutes.orderDetails, extra: order);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text('View Details', style: GoogleFonts.sen(color: Colors.black)),
            ),
          ),
        ],
      );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ongoing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.ongoing: return 'Ongoing';
      case OrderStatus.completed: return 'Completed';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RestaurantProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors1.circleAvatarBackGrey,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            ),
          ),
        ),
        title: Text('Order Details', style: GoogleFonts.sen(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text('Items (${order.totalItems})', style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final entry = order.items[index];
                return _buildOrderItem(entry.key, entry.value);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildPriceSummary(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, provider),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.vendor, style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(order.orderId, style: GoogleFonts.sen(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat.yMMMd().format(order.orderDate), style: GoogleFonts.sen(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 4),
              Container(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(MenuItem item, int quantity) {
    // Helper to parse price string like '$9.99' to double
    double price = double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double itemTotal = price * quantity;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.imageUrls?.first ?? 'assets/images/placeholder.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Qty: $quantity', style: GoogleFonts.sen(color: Colors.grey[600])),
            ],
          ),
        ),
        Text('\$${itemTotal.toStringAsFixed(2)}', style: GoogleFonts.sen(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPriceSummary() {
    // Note: Delivery fee is hardcoded as it's not part of the Order model.
    const double deliveryFee = 5.00;
    final double subtotal = order.totalPrice > deliveryFee ? order.totalPrice - deliveryFee : order.totalPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Summary', style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _buildSummaryRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
        const Divider(height: 24),
        _buildSummaryRow('Total', '\$${order.totalPrice.toStringAsFixed(2)}', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.sen(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey[700])),
        Text(value, style: GoogleFonts.sen(fontSize: isTotal ? 20 : 16, fontWeight: FontWeight.bold, color: isTotal ? Colors.black : Colors.grey[800])),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, RestaurantProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: Text('REORDER', style: GoogleFonts.sen(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            provider.reorder(order);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Items from order ${order.orderId} added to cart.'),
              action: SnackBarAction(
                label: 'VIEW CART',
                textColor: Colors1.lightyellow,
                onPressed: () {
                  context.pop(); // Close details page
                  context.push(AppRoutes.cart); // Go to cart
                },
              ),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors1.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ongoing: return Colors.blue;
      case OrderStatus.completed: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
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
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isFormVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content:
                        const Text('Are you sure you want to clear the cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clear();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Cart items list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, index) {
                      final cartItem = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: FittedBox(
                                  child: Text('₹${cartItem.item.itemPrice}'),
                                ),
                              ),
                            ),
                            title: Text(cartItem.item.itemName),
                            subtitle: Text(
                                'Total: ₹${(cartItem.item.itemPrice * cartItem.quantity).toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    cart.updateQuantity(cartItem.item.id!,
                                        cartItem.quantity - 1);
                                  },
                                ),
                                Text('${cartItem.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cart.updateQuantity(cartItem.item.id!,
                                        cartItem.quantity + 1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      cart.removeItem(cartItem.item.id!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Cart summary
                  Card(
                    margin: const EdgeInsets.all(15),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 20),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(
                              '₹${cart.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isFormVisible = !_isFormVisible;
                              });
                            },
                            child: Text(
                              _isFormVisible ? 'Hide Form' : 'Checkout',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Order form
                  if (_isFormVisible)
                    Card(
                      margin: const EdgeInsets.all(15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitOrder(cart);
                                  }
                                },
                                child: const Text(
                                  'Place Order',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _submitOrder(Cart cart) {
    // Here you would typically send the order to a backend
    // For this example, we'll just show a success dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order Placed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been placed successfully!'),
            const SizedBox(height: 10),
            Text('Name: ${_nameController.text}'),
            Text('Email: ${_emailController.text}'),
            Text('Address: ${_addressController.text}'),
            Text('Phone: ${_phoneController.text}'),
            const SizedBox(height: 10),
            Text('Total Amount: ₹${cart.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to the product screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

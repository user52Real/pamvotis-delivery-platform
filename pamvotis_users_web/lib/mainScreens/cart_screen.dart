import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pamvotis_users_web/mainScreens/home_screen.dart';
import '/assistantMethods/assistant_methods.dart';
import '/assistantMethods/cart_item_counter.dart';
import '/assistantMethods/total_amount.dart';
import '/mainScreens/address_screen.dart';
import '/models/items.dart';
import '/splashScreen/splash_screen.dart';
import '/widgets/cart_item_design.dart';
import '/widgets/progress_bar.dart';
import '/widgets/error_dialog.dart';
import '/widgets/loading_dialog.dart';
import '/services/payment_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final String? sellerUID;
  CartScreen({this.sellerUID});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<int>? separateItemQuantityList;
  num totalAmount = 0;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(0);
    separateItemQuantityList = separateItemQuantities();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(),
            body: Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: 20,
                ),
                constraints: BoxConstraints(
                  maxWidth: 1200,
                  minHeight: constraints.maxHeight * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildResponsiveLayout(constraints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    if (constraints.maxWidth > 900) {
      return _buildWideLayout();
    } else {
      return _buildNarrowLayout();
    }
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildCartList()),
            ],
          ),
        ),
        Container(
          width: 2,
          margin: const EdgeInsets.symmetric(vertical: 20),
          color: Colors.grey.shade200,
        ),
        Expanded(
          child: Column(
            children: [
              _buildPaymentMethodSelector(),
              const Spacer(),
              _buildBottomButtons(),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Pamvotis",
        style: TextStyle(fontSize: 32, fontFamily: "Lexend"),
      ),
      centerTitle: true,
      actions: [_buildCartIcon()],

    );
  }

  Widget _buildCartIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {},
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Center(
              child: Consumer<CartItemCounter>(
                builder: (context, counter, _) {
                  return Text(
                    counter.count.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        children: [
          const Text(
            "Shopping Cart",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
            ),
          ),
          const SizedBox(height: 10),
          Consumer2<TotalAmount, CartItemCounter>(
            builder: (context, amountProvider, cartProvider, _) {
              return cartProvider.count == 0
                  ? Container()
                  : Text(
                "Total: €${amountProvider.tAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Lexend",
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildCartList()),
        _buildPaymentMethodSelector(),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildCartList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("items")
          .where("itemID", whereIn: separateItemIDs())
          .orderBy("publishedDate", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: circularProgress());
        }
        if (snapshot.data!.docs.isEmpty) {
          return _buildEmptyCart();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Items model = Items.fromJson(
              snapshot.data!.docs[index].data()! as Map<String, dynamic>,
            );

            if (index == 0) {
              totalAmount = model.price! * separateItemQuantityList![index];
            } else {
              totalAmount += model.price! * separateItemQuantityList![index];
            }

            if (index == snapshot.data!.docs.length - 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<TotalAmount>(context, listen: false)
                    .displayTotalAmount(totalAmount.toDouble());
              });
            }

            return CartItemDesign(
              model: model,
              context: context,
              quanNumber: separateItemQuantityList![index],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
              fontFamily: "Lexend",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
            ),
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Cash on Delivery'),
            value: PaymentMethod.cash,
            groupValue: _selectedPaymentMethod,
            onChanged: (PaymentMethod? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Pay with Card'),
            value: PaymentMethod.stripe,
            groupValue: _selectedPaymentMethod,
            onChanged: (PaymentMethod? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == PaymentMethod.stripe) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => LoadingDialog(message: "Processing Payment"),
        );

        await PaymentService.makeStripePayment(
          totalAmount: totalAmount.toDouble(),
          context: context,
          onSuccess: () async {
            Navigator.pop(context); // Dismiss loading dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => AddressScreen(
                  totalAmount: totalAmount.toDouble(),
                  sellerUID: widget.sellerUID,
                  paymentMethod: "paid",
                ),
              ),
            );
          },
        );
      } catch (e) {
        Navigator.pop(context); // Dismiss loading dialog
        showDialog(
          context: context,
          builder: (c) => ErrorDialog(message: e.toString()),
        );
      }
    } else {
      // Cash on delivery
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => AddressScreen(
            totalAmount: totalAmount.toDouble(),
            sellerUID: widget.sellerUID,
            paymentMethod: "cash_on_delivery",
          ),
        ),
      );
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                clearCartNow(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const HomeScreen()));
                Fluttertoast.showToast(msg: "Cart has been cleared");
              },
              icon: const Icon(Icons.clear_all),
              label: const Text(
                "Clear Cart",
                style: TextStyle(fontSize: 16, fontFamily: "Lexend"),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => AddressScreen(
                      totalAmount: totalAmount.toDouble(),
                      sellerUID: widget.sellerUID,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text(
                "Proceed",
                style: TextStyle(fontSize: 16, fontFamily: "Lexend"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum PaymentMethod { cash, stripe }
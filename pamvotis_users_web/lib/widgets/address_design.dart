import 'package:flutter/material.dart';
import '/assistantMethods/address_changer.dart';
import '/mainScreens/placed_order_screen.dart';
import '/maps/maps.dart';
import '/models/address.dart';
import 'package:provider/provider.dart';

class AddressDesign extends StatefulWidget {
  final Address? model;
  final int? currentIndex;
  final int? value;
  final String? addressId;
  final double? totalAmount;
  final String? sellerUID;
  final String? paymentMethod;

  AddressDesign({
    this.model,
    this.currentIndex,
    this.value,
    this.addressId,
    this.totalAmount,
    this.sellerUID,
    this.paymentMethod = "cash_on_delivery",
  });

  @override
  State<AddressDesign> createState() => _AddressDesignState();
}

class _AddressDesignState extends State<AddressDesign> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Provider.of<AddressChanger>(context, listen: false)
                .displayResult(widget.value);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio(
                      groupValue: widget.currentIndex!,
                      value: widget.value!,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        Provider.of<AddressChanger>(context, listen: false)
                            .displayResult(val);
                      },
                    ),
                    Expanded(
                      child: _buildAddressDetails(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text("Check on Maps"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          MapsUtils.openMapWithPosition(
                              widget.model!.lat!, widget.model!.lng!);
                        },
                      ),
                    ),
                    if (widget.value ==
                        Provider.of<AddressChanger>(context).count) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => PlacedOrderScreen(
                                      addressId: widget.addressId,
                                      totalAmount: widget.totalAmount,
                                      sellerUID: widget.sellerUID,
                                    )));
                          },
                          child: const Text(
                            "Proceed",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Lexend",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressDetails() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(2),
      },
      children: [
        _buildTableRow("Name", widget.model!.name),
        _buildTableRow("Phone", widget.model!.phoneNumber),
        _buildTableRow("Flat", widget.model!.flatNumber),
        _buildTableRow("City", widget.model!.city),
        _buildTableRow("Country", widget.model!.state),
        _buildTableRow("Address", widget.model!.fullAddress),
      ],
    );
  }

  TableRow _buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            "$label:",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value ?? "",
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: "Lexend",
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
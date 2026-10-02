import 'package:flutter/material.dart';

import 'package:online_database_firebase/A_Firebase/model/product_model.dart';
import 'package:online_database_firebase/A_Firebase/model/stock_model.dart';
import 'package:online_database_firebase/A_Firebase/service/product_service.dart';
import 'package:online_database_firebase/A_Firebase/service/stock_transaction_service.dart';

class FbStockscreen extends StatefulWidget {
  const FbStockscreen({super.key});

  @override
  State<FbStockscreen> createState() => _FbStockscreenState();
}

class _FbStockscreenState extends State<FbStockscreen> {
  // SERVICES

  final ProductService _productService = ProductService();

  final StockTransactionService _stockTransactionService =
      StockTransactionService();

  // CONTROLLERS

  final TextEditingController _quantityController = TextEditingController();

  // STATE
  String? _selectedProduct;

  int? _currentProductQty;

  // true  = ADD / IN
  // false = SUBTRACT / OUT
  bool stockOperationController = true;

  bool _isLoading = false;

  // CALCULATED STOCK

  int? get updatedStock {
    if (_currentProductQty == null) {
      return null;
    }

    final quantity = int.tryParse(_quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      return _currentProductQty;
    }

    if (stockOperationController) {
      return _currentProductQty! + quantity;
    }

    final result = _currentProductQty! - quantity;

    if (result < 0) {
      return null;
    }

    return result;
  }

  // ENTERED QUANTITY

  int get enteredQuantity {
    return int.tryParse(
          _quantityController.text.trim(),
        ) ??
        0;
  }

  // CAN SAVE

  bool get canSave {
    if (_selectedProduct == null) {
      return false;
    }

    if (_currentProductQty == null) {
      return false;
    }

    if (enteredQuantity <= 0) {
      return false;
    }

    if (!stockOperationController && enteredQuantity > _currentProductQty!) {
      return false;
    }

    return !_isLoading;
  }

  // OPERATION

  void setOperation({
    required bool isAdding,
  }) {
    if (_isLoading) return;

    setState(() {
      stockOperationController = isAdding;
    });
  }

  // PRODUCT CHANGE

  Future<void> _changedCategoryItem(
    String? value,
  ) async {
    if (value == null || _isLoading) {
      return;
    }

    setState(() {
      _selectedProduct = value;
      _currentProductQty = null;
      _quantityController.clear();
    });

    try {
      final gotQty = await _productService.getCurrentStock(value);

      if (!mounted) return;

      setState(() {
        _currentProductQty = gotQty;
      });
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        "Failed to load stock",
        Colors.red,
      );
    }
  }

  // SAVE STOCK

  Future<void> addStockRecord() async {
    if (_isLoading) return;

    // PRODUCT VALIDATION

    if (_selectedProduct == null) {
      _showSnackBar(
        "Please select a product",
        Colors.orange,
      );
      return;
    }

    // QUANTITY VALIDATION

    final int? newStockInput = int.tryParse(
      _quantityController.text.trim(),
    );

    if (newStockInput == null || newStockInput <= 0) {
      _showSnackBar(
        "Enter a valid quantity",
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String productId = _selectedProduct!;

      // GET FRESH STOCK

      final int freshCurrentStock = await _productService.getCurrentStock(
        productId,
      );

      // OPERATION

      final String transactionType = stockOperationController ? "IN" : "OUT";

      // CALCULATE STOCK

      final int calculatedStock;

      if (stockOperationController) {
        calculatedStock = freshCurrentStock + newStockInput;
      } else {
        calculatedStock = freshCurrentStock - newStockInput;
      }

      // PREVENT NEGATIVE STOCK

      if (calculatedStock < 0) {
        if (!mounted) return;

        _showSnackBar(
          "Not enough stock available",
          Colors.red,
        );

        return;
      }

      // UPDATE PRODUCT

      await _productService.updateStock(
        productId,
        calculatedStock,
      );

      // TRANSACTION RECORD

      final transactionModel = StockTransactionModel(
        productId: productId,
        type: transactionType,

        // IMPORTANT:
        // Save adjustment quantity,
        // not resulting stock.
        quantity: newStockInput,

        date: DateTime.now(),
      );

      await _stockTransactionService.addStockTransaction(
        transactionModel,
      );

      if (!mounted) return;

      setState(() {
        _currentProductQty = calculatedStock;

        _quantityController.clear();
      });

      _showSnackBar(
        stockOperationController
            ? "Stock added successfully"
            : "Stock subtracted successfully",
        stockOperationController ? Colors.green : Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        "Database Error: ${e.toString()}",
        Colors.red,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Stock Management",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HEADER

                      _buildHeader(),

                      const SizedBox(
                        height: 20,
                      ),

                      // PRODUCT CARD

                      _buildProductCard(),

                      const SizedBox(
                        height: 16,
                      ),

                      // OPERATION CARD

                      _buildOperationCard(),

                      const SizedBox(
                        height: 20,
                      ),

                      // SAVE BUTTON

                      _buildSaveButton(),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Colors.indigo,
            size: 28,
          ),
        ),
        const SizedBox(
          width: 14,
        ),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Stock",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Add or subtract product inventory",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PRODUCT CARD

  Widget _buildProductCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE

          Row(
            children: [
              _sectionIcon(
                Icons.shopping_bag_outlined,
                Colors.indigo,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Product",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          // DROPDOWN

          StreamBuilder<List<ProductModel>>(
            stream: _productService.fetchProduct(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(
                    14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(
                      0.08,
                    ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    "Unable to load products",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                );
              }

              final products = snapshot.data ?? [];

              return DropdownButtonFormField<String>(
                value: _selectedProduct,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                ),
                decoration: InputDecoration(
                  hintText: "Select a product",
                  filled: true,
                  fillColor: const Color(
                    0xffF8F9FC,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                    borderSide: const BorderSide(
                      color: Colors.indigo,
                      width: 1.5,
                    ),
                  ),
                ),
                items: products.map(
                  (product) {
                    return DropdownMenuItem<String>(
                      value: product.id,
                      child: Text(
                        product.productName ?? "Unnamed Product",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
                onChanged: _isLoading ? null : _changedCategoryItem,
              );
            },
          ),

          const SizedBox(
            height: 16,
          ),

          // CURRENT STOCK
          _buildCurrentStock(),
        ],
      ),
    );
  }

  // CURRENT STOCK

  Widget _buildCurrentStock() {
    final hasProduct = _selectedProduct != null;

    final loading = hasProduct && _currentProductQty == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.inventory_outlined,
              color: Colors.blue,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Stock",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Available quantity",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!hasProduct)
            const Text(
              "--",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
              ),
            )
          else if (loading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else
            Text(
              "$_currentProductQty",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.indigo,
              ),
            ),
        ],
      ),
    );
  }

  // OPERATION CARD

  Widget _buildOperationCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE

          Row(
            children: [
              _sectionIcon(
                Icons.swap_vert_rounded,
                Colors.deepPurple,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Stock Operation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          // ADD / SUBTRACT SEGMENT

          _buildOperationSelector(),

          const SizedBox(
            height: 22,
          ),

          // QUANTITY

          const Text(
            "Quantity",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          TextField(
            controller: _quantityController,
            enabled: !_isLoading,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: const TextStyle(
                color: Colors.black26,
                fontSize: 30,
              ),
              filled: true,
              fillColor: const Color(
                0xffF8F9FC,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                borderSide: BorderSide(
                  color: stockOperationController ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // CALCULATION

          _buildCalculationPreview(),
        ],
      ),
    );
  }

  // OPERATION SELECTOR

  Widget _buildOperationSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xffF1F3F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ADD

          Expanded(
            child: GestureDetector(
              onTap: () {
                setOperation(
                  isAdding: true,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: stockOperationController
                      ? Colors.green
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: stockOperationController
                          ? Colors.white
                          : Colors.green,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      "Add Stock",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: stockOperationController
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SUBTRACT

          Expanded(
            child: GestureDetector(
              onTap: () {
                setOperation(
                  isAdding: false,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: !stockOperationController
                      ? Colors.red
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove,
                      color:
                          !stockOperationController ? Colors.white : Colors.red,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      "Subtract",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: !stockOperationController
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CALCULATION PREVIEW

  Widget _buildCalculationPreview() {
    final current = _currentProductQty;

    final quantity = enteredQuantity;

    final isSubtract = !stockOperationController;

    final insufficientStock =
        isSubtract && current != null && quantity > current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insufficientStock
            ? Colors.red.withOpacity(0.06)
            : stockOperationController
                ? Colors.green.withOpacity(
                    0.06,
                  )
                : Colors.red.withOpacity(
                    0.06,
                  ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insufficientStock
              ? Colors.red.withOpacity(
                  0.3,
                )
              : stockOperationController
                  ? Colors.green.withOpacity(
                      0.2,
                    )
                  : Colors.red.withOpacity(
                      0.2,
                    ),
        ),
      ),
      child: Column(
        children: [
          _calculationRow(
            "Current Stock",
            current == null ? "--" : "$current",
            Colors.black87,
          ),
          const SizedBox(
            height: 10,
          ),
          _calculationRow(
            stockOperationController ? "Adding" : "Subtracting",
            current == null || quantity <= 0
                ? "--"
                : stockOperationController
                    ? "+$quantity"
                    : "-$quantity",
            stockOperationController ? Colors.green : Colors.red,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Divider(
              height: 1,
            ),
          ),
          _calculationRow(
            "New Stock",
            insufficientStock
                ? "--"
                : updatedStock == null
                    ? "--"
                    : "$updatedStock",
            insufficientStock ? Colors.red : Colors.indigo,
            bold: true,
          ),
          if (insufficientStock) ...[
            const SizedBox(
              height: 12,
            ),
            Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  child: Text(
                    "Not enough stock available for this operation.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // CALCULATION ROW

  Widget _calculationRow(
    String title,
    String value,
    Color valueColor, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.black54,
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: bold ? 20 : 15,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // SAVE BUTTON

  Widget _buildSaveButton() {
    final isAdd = stockOperationController;

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSave ? addStockRecord : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAdd ? Colors.indigo : Colors.redAccent,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAdd ? Icons.add : Icons.remove,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    isAdd ? "Add Stock" : "Subtract Stock",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // CARD

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // SECTION ICON

  Widget _sectionIcon(
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}

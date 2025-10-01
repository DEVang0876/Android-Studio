class CartError implements Exception 
{
  final String message;
  CartError(this.message);
  @override
  String toString() => 'CartError: $message';
}

double calculateTotal(
  {
  required Map<String, double> priceList,
  required Map<String, int> cartQuantities,
}) {
  
  double total = 0.0;
  cartQuantities.forEach((item, qty) 
  {
    if (!priceList.containsKey(item)) 
    {
      throw CartError('Missing item in price list: $item');
    }
    if (qty < 0) 
    {
      throw CartError('Negative quantity for item: $item');
    }
    total += priceList[item]! * qty;
  });
  return double.parse(total.toStringAsFixed(2));
}

void main() {
  print('Shopping Cart Total');
  final priceList = <String, double>
  {
    'apple': 30.0,
    'banana': 10.0,
    'milk': 50.0,
  };
  final cart = <String, int>
  {
    'apple': 3,
    'milk': 2,
    'banana': 5,
  };

  try {
    final total = calculateTotal(priceList: priceList, cartQuantities: cart);
    print('Total: ₹$total');
  } on CartError catch (e) {
    print(e);
  }

  final badCart = <String, int>{'orange': 2, 'apple': -1};
  try 
  {
    final total = calculateTotal(priceList: priceList, cartQuantities: badCart);
    print('Total: ₹$total');
  } on CartError catch (e) {
    print('Handled error -> $e');
  }
  print('');
}

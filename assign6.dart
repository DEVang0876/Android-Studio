
class BankAccount 
{
  String? accountHolder; 
  double _balance = 0.0;

  BankAccount({this.accountHolder, double initialBalance = 0.0}) 
  {
    if (initialBalance < 0) 
    {
      throw ArgumentError('Initial balance cannot be negative');
    }
    _balance = initialBalance;
  }

  double get balance => double.parse(_balance.toStringAsFixed(2));

  set balance(double newBalance) 
  {
    if (newBalance < 0) 
    {
      throw ArgumentError('Balance cannot be negative');
    }
    _balance = newBalance;
  }

  void deposit(double amount) 
  {
    if (amount <= 0) 
    {
      throw ArgumentError('Deposit must be positive');
    }
    _balance += amount;
  }

  void withdraw(double amount) 
  {
    if (amount <= 0) 
    {
      throw ArgumentError('Withdrawal must be positive');
    }
    if (amount > _balance) 
    {
      throw ArgumentError('Insufficient funds');
    }
    _balance -= amount;
  }

  @override
  String toString() =>
      'Account(${accountHolder ?? "Unnamed"}): ₹${balance.toStringAsFixed(2)}';
}

void main() 
{
  print('Bank Transactions');
  final acc = BankAccount(accountHolder: null, initialBalance: 1000);
  print(acc);
  acc.deposit(500);
  print('After deposit: ${acc}');
  try {
    acc.withdraw(1800);
  } catch (e) {
    print('Error: $e');
  }
  acc.withdraw(200);
  print('After withdraw: ${acc}');
  acc.accountHolder = 'Kiran';
  print('Named: ${acc}');
  print('');
}

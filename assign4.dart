
abstract class Book 
{
  final String title;
  final String author;
  Book(this.title, this.author);
  void displayInfo();
}

class EBook extends Book 
{
  final double fileSizeMB;
  final String format;
  EBook(super.title, super.author, this.fileSizeMB, this.format);

  @override
  void displayInfo() {
    print('EBook: "$title" by $author, $fileSizeMB MB, $format');
  }
}

class PrintedBook extends Book 
{
  final int pages;
  PrintedBook(super.title, super.author, this.pages);

  @override
  void displayInfo() 
  {
    print('Printed: "$title" by $author, $pages pages');
  }
}

void main() 
{
  print('Polymorphism Display');
  final books = <Book>[
    EBook('I\'ll be never get older', 'DEVINE', 3.2, 'PDF'),
    PrintedBook('Her Compulsion', 'Robert C. Martin', 464),
  ];    

  for (final b in books) {
    b.displayInfo();
  }
  print('');
}

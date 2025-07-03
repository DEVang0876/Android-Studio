import 'dart:io';

void main(){
  stdout.write("Enter No1 : ");
  var n1 = stdin.readLineSync();
  stdout.write("Enter No2 : ");
  var n2 = stdin.readLineSync();
  stdout.write("Enter No3 : ");
  var n3 = stdin.readLineSync();
  stdout.write("Enter No4 : ");
  var n4 = stdin.readLineSync();
  stdout.write("Enter No5 : ");
  var n5 = stdin.readLineSync();

  var mylist = [n1, n2, n3, n4, n5];
  print("List is $mylist");

  var n;
  stdout.write("Enter 1 for add data ,Enter 2 for remove data.");
  n = stdin.readLineSync();
  if(n == "1"){
    stdout.write("Enter data to add : ");
    var data = stdin.readLineSync();
    mylist.add(data);
    print("List after adding data : $mylist");
  }else if(n == "2"){
    stdout.write("Enter data to remove : ");
    var data = stdin.readLineSync();
    mylist.remove(data);
    print("List after removing data : $mylist");
  }else{
    print("Invalid option selected."); 
    }
}
import 'dart:io';

void main(){
  stdout.write("Enter No1");
  var a = stdin.readLineSync();
  print("A value is $a");
  print("Enter No2");
  var b = stdin.readLineSync();
  print("B value is $b");
  var c = int.parse(a!) + int.parse(b!);
  print("Sum is $c");

  if(c == 30){
    print("C is 30");
  }else if(c >30){
    print("C is > 30");
  }else{
    print("C is < 30");
  }
}


// Property를 이용한 방법
class Calc03{
  // Property(Attribute, Field)
  int _num1 = 0;  // Private 속성
  int _num2 = 0;  // Private 속성

  // Constructor(생성자)
  Calc03(int num1, int num2)
  : _num1 = num1,
    _num2 = num2;
  
  // Method
  int addition() {
    return _num1 + _num2;
  }

  int subtraction() {
    return _num1 - _num2;
  }

  int multiplication() {
    return _num1 * _num2;
  }

  double division() {
    return _num1 / _num2;
  }
} // Calc03
package uk.ac.soton.ecs.rdc1g10.cw1.test;


public class TestClass {
	public static void main(String[] args) {
		A a = new A("hello");
		A b = new A("hello", 1);
		a.c = "hello again";
		A.d = 1;
		a.setA("test");
		a.setB(0);
		b.setA("tests");
		b.setB(2);
	}
}
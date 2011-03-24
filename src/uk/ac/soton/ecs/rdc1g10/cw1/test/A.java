package uk.ac.soton.ecs.rdc1g10.cw1.test;



@Logging
public class A {
	private String a;
	private int b;
	public String c;
	public static int d;
	
	public A(String a) {
		this.a = a;
	}
	
	public A(String a, int b) {
		this(a);
		this.b = b;
	}

	public String getA() {
		return a;
	}

	public void setA(String a) {
		this.a = a;
	}

	public int getB() {
		return b;
	}

	public void setB(int b) {
		this.b = b;
	}	
}

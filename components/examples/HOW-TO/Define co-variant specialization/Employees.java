/*
Java (tm) example on Employees with specialization
(C) 2024, Manfred Jeusfeld

Trademarks are owned by their respective owners.

The sources and documentation in this directory are governed by the license
https://creativecommons.org/licenses/by-sa/4.0/
*/

// To simplify compilation, we embed all required classes in a single file

import java.util.*;

class Project {
  String projid;
  int budget;

  Project(String projid, int budget) {
    this.projid = projid;
    this.budget = budget;
  }
} // Project


class HighLevelProject extends Project {

  // High-level project must have a certain minimum budget. This is a business rule.
  HighLevelProject(String projid, int budget) {
    super(projid,budget);
    assert (budget >= 1000000): "E1-Attempt to create a HighLevelProject with insufficient budget";
  }
} //HighLevelProject


   
class Employee {

   String name;
   int salary;
   Project project;

   Employee(String empname) {
      this.name = empname;
      this.salary = 0;
   }

   void setMinimumSalary() {
      this.salary = 1000;
   }

   void assignProject(Project p) {
      this.project = p;
   }

   void printEmployee() {
      System.out.print(this.name + " earns " + this.salary +". " );
      if (project != null) 
         System.out.print("Project: " + this.project.projid);
      System.out.println();
   }

}  // Employee


class Manager extends Employee {

  String position;
  HighLevelProject project;  // refinement of Employee.project; not safeguarded by Java

  Manager(String manname, String manposition) {
    super(manname);
    this.position = manposition;
  }

// refinement of method parameters is not accepted in Java
//  @Override void assignProject(HighLevelProject p) {
//     this.project = p;
//  }


// A way to refine by runtime checking of the parameter p
// The statement that Managers can only be assigned to HighLevelProject is a domain rule
// We somehow need to ensure this rule. This solution is type-safe wrt. to the
// definition of the variable 'project' in class Manager.

// If you disable this overriding method and instead use Employee.assignProject(p) for
// a simple instance p of Project, then Java runtime will *not* execute the assignment 
// but without rasining any exception.

  @Override void assignProject(Project p) {
     if (p instanceof HighLevelProject) 
       this.project = (HighLevelProject) p; // type casting will succeed because of the instanceof test
     else
       System.out.println("Not a HighLevelProject for " + this.name + ": " + p.projid);
  } 


  @Override void setMinimumSalary() {
      salary = 2000;
   }

  // This overrides the printEmployee method of Employee by adding the manager's position to the printed line
  // Like setMinimumSalary(), it specializes the methods to instances of Manager

  @Override void printEmployee() {
      System.out.print(position + " " + this.name + " earns " + this.salary +". " );
      if (this.project != null) 
         System.out.print("Project: " + this.project.projid);
      System.out.println();
   }

} // Manager




// This is the main class Employees. It provides the ability to manage sets of employees

class Employees {

   List<Employee> emplist;


   Employees() {
      this.emplist = new ArrayList<Employee>();
   } 

   void addEmployee(Employee e) {
     this.emplist.add(e);
   }

   // illustrate Liskov substitution principle
   void assignDefaultProject() {
      Project dp = new Project("P0000",0);  // this is in particular not a HighLevelProject
      for (Employee emp: this.emplist) {
        // note that emp could be a Manager, the programmer assumes the signature of Employee.assignProject()
        emp.assignProject(dp);  
      }
   }

   void printEmployees() {
      System.out.println("\nThis employee list has " + this.emplist.size() + " members:");
      for (Employee emp: this.emplist) {
        emp.printEmployee();  // will use the appropriate printEmployee() method depending on the class of emp
      }
   }


   public static void main(String[] args) {

      // the class Employee stands for the type of all possible instances of Employee
      // the class Employees maintains a finite list of instances of Employee
      Employees employees = new Employees();

      // Let's test our classes
 
      Project p1 = new Project("P1001",100000);
      Project p2 = new Project("P2001",500000);

      Employee bill = new Employee("William");
      bill.assignProject(p1);
      bill.setMinimumSalary();

      Manager mary = new Manager("Mary", "CEO");

      mary.setMinimumSalary(); // since mary is a manager, she gets the Manager's minimum salary assigned here
      mary.assignProject(p2);  // this one fails because p2 is not a HighLevelProject

      Project p3 = new HighLevelProject("P3001",1500000);
      mary.assignProject(p3);  // this one succeeds

      // this one would not pass the assertion of HighLevelProject() if assertions are enabled
      Project p4 = new HighLevelProject("P4001",50000);  

      employees.addEmployee(bill);
      employees.addEmployee(mary);
      employees.addEmployee(new Manager("Anne", "CISO"));  // a third employee added to the list

      employees.printEmployees();

      // this would create problems for instances of Manager if "enforce assertions" flag is used
      employees.assignDefaultProject();
      

   } // main

} // Employees




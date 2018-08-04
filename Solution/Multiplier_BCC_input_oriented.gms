******Mohammad Sadegh Ghasemi 965051511******
******Multiplier BCC (input oriented)******

* Defining Indexes
Sets
  i "Inputs"   /I1, I2, I3/
  r "Outputs"  /O1/
  j "Units"    /B01*B41/;

Alias (j, l);

* Importing Inputs
Table x(j,i)
$include "Data/R41/I41.txt";

* Importing Outputs
Table y(j, r)
$include "Data/R41/O41.txt";

Variables
  z    "Efficiency"
  u0   "variable return to scale";
Positive variables
  v(i) "Input weights"
  u(r) "Output weights";


* Temporary Scalars for calculating Reference Unit X
Scalar I1, I2, I3;

Parameters
  x0(i) "Inputs of under evaluation DMU",
  y0(r) "Outputs of under evaluation DMU";

Equations
  Objective
  Const1
  Const2(j);


Objective..  z =e= Sum(r, y0(r) * u(r)) + u0;
Const1..     Sum(i, x0(i) * v(i)) =e= 1;
Const2(j)..  Sum(r, y(j, r) * u(r)) - Sum(i, x(j, i) * v(i)) + u0 =l= 0;

Model Multiplier_BCC /All/;

* Results including Reference Points will save in this file 
File BCC_Model /Multiplier_BCC_input_oriented_results.txt/;


Puttl BCC_Model 'DMU':10, 'Efficiency':12, 'Reference Unit (I1, I2, I3, Y1)'//;
Put BCC_Model;

* Calculating Efficiency and Reference points for each unit
Loop(l,
  Loop(i, x0(i) = x(l, i));
  Loop(r, y0(r) = y(l, r));

  Solve Multiplier_BCC Using LP Maximizing z;

* Saving results to Multiplier_BCC_input_oriented_results.txt
  Put l.tl:10;
  if ((Multiplier_BCC.modelstat eq 1),
    Put z.l:7:5;

    if (1 - z.l < 0.00001,
      Put  "     Efficient Unit";
    else 
* Calculating X(input) of Reference Point
      I1 = z.l * x0('I1');
      I2 = z.l * x0('I2');
      I3 = z.l * x0('I3');

      Put '     (' I1:10:4 ', ' I2:10:4 ', ' I3:10:4 ', ' y0('O1'):6:1 ')';
    );

  elseif Multiplier_BCC.modelstat eq 3,
    Put "     Unbounded";
  elseif Multiplier_BCC.modelstat eq 4,
    Put "     Infeasible";
  );
  Put /;
  
);

Putclose;

******Mohammad Sadegh Ghasemi 965051511******
******Multiplier CCR (output oriented)******

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
  z    "Efficiency";

Positive variables
  v(i) "Input weights"
  u(r) "Output weights";


* Temporary Scalar for calculating Reference Unit Y
Scalar O1;

Parameters
  x0(i) "Inputs of under evaluation DMU",
  y0(r) "Outputs of under evaluation DMU";

Equations
  Objective
  Const1
  Const2(j);


Objective..  z =e= Sum(i, x0(i) * v(i));
Const1..     Sum(r, y0(r) * u(r)) =e= 1;
Const2(j)..  Sum(i, x(j, i) * v(i)) - Sum(r, y(j, r) * u(r)) =g= 0;

Model Multiplier_CCR /All/;

* Results including Reference Points will save in this file 
File CCR_Model /Multiplier_CCR_output_oriented_results.txt/;


Puttl CCR_Model 'DMU':10, 'z':11, 'Reference Unit (I1, I2, I3, Y1)'//;
Put CCR_Model;

* Calculating Efficiency and Reference points for each unit
Loop(l,
  Loop(i, x0(i) = x(l, i));
  Loop(r, y0(r) = y(l, r));

  Solve Multiplier_CCR Using LP Minimizing z;

* Saving results to Multiplier_CCR_output_oriented_results.txt
  Put l.tl:10;
  if ((Multiplier_CCR.modelstat eq 1),
    Put z.l:7:5;

    if (z.l - 1 < 0.00001,
      Put  "    Efficient Unit";
    else 
* Calculating Y(output) of Reference Point
      O1 = z.l * y0('O1');
      Put '    (' x0('I1'):10:4 ', ' x0('I2'):10:4 ', ' x0('I3'):10:4 ', ' O1:6:1 ')';
    );

  elseif Multiplier_CCR.modelstat eq 3,
    Put "    Unbounded";
  elseif Multiplier_CCR.modelstat eq 4,
    Put "    Infeasible";
  );
  Put /;
  
);

Putclose;

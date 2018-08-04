******Mohammad Sadegh Ghasemi 965051511******
******Envelopment BCC (output oriented)******

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

Variables z, Phi;
Positive Variables
  Lambda(j)
  v(i) "Input weights"
  u(r) "Output weights"
  s(i)  "Input excess",
  t(r)  "Output shortfall";

* Temporary Scalar for calculating Reference Unit Y
Scalar O1;

Parameters
  x0(i) "Inputs of under evaluation DMU",
  y0(r) "Outputs of under evaluation DMU";

Equations
  Objective,
  Input_Const(i),
  Output_Const(r),
  Lambda_Const;

Objective..  z =e= Phi;
Input_Const(i)..   Sum(j, x(j, i) * Lambda(j)) =l= x0(i);
Output_Const(r)..   Sum(j, y(j, r) * Lambda(j)) =g= Phi * y0(r);
Lambda_Const..   Sum(j, Lambda(j)) =e= 1;

* Results including Reference Points will save in this file 
File BCC_Model /Envelopment_BCC_output_oriented_results.txt/ ;

Model Envelopment_BCC /Objective,
                   Input_Const,
                   Output_Const,
                   Lambda_Const/;

Puttl BCC_Model 'DMU':10, 'Phi':11, 'Reference Unit (I1, I2, I3, Y1)'//;
Put BCC_Model;

* Calculating Phi and Reference points for each unit
Loop(l,
  Loop(i, x0(i) = x(l, i));
  Loop(r, y0(r) = y(l, r));

  Solve Envelopment_BCC Using LP Maximizing z;

* Saving results to Envelopment_BCC_output_oriented_results.txt
  Put l.tl:10;
  if (Envelopment_BCC.modelstat eq 1,
    Put z.l:7:5;

    if (z.l - 1 < 0.00001,
      Put  "    Efficient Unit";
    else 
* Calculating Y(output) of Reference Point
      O1 = z.l * y0('O1');
      
      Put '    (' x0('I1'):10:4 ', ' x0('I2'):10:4 ', ' x0('I3'):10:4 ', ' O1:6:1 ')';
    );

  elseif Envelopment_BCC.modelstat eq 3,
    Put "    Unbounded";
  elseif Envelopment_BCC.modelstat eq 4,
    Put "    Infeasible";
  );
  Put /;

);

Putclose;
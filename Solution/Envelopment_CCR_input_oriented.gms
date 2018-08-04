******Mohammad Sadegh Ghasemi 965051511******
******Envelopment CCR (input oriented)******

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

* Phase 1 Variables
Variables z, Theta;
Positive Variables Lambda(j);

* Phase 2 Variables
Variables w;
Positive Variables
  s(i)  "Input excess",
  t(r)  "Output shortfall";

* Temporary Scalars for calculating Reference Unit X
Scalar I1, I2, I3;

Parameters
  x0(i) "Inputs of under evaluation DMU",
  y0(r) "Outputs of under evaluation DMU";

Equations
  Phase1_Objective,
  Phase1_Input_Const(i),
  Phase1_Output_Const(r),

  Phase2_Objective,
  Phase2_Input_Const(i),
  Phase2_Output_Const(r);

* Phase 1 Equations
Phase1_Objective..  z =e= Theta;
Phase1_Input_Const(i)..   Sum(j, x(j, i) * Lambda(j)) =l= Theta * x0(i);
Phase1_Output_Const(r)..   Sum(j, y(j, r) * Lambda(j)) =g= y0(r);

* Phase 2 Equations
Phase2_Objective..  w =e= Sum(i, s(i)) + Sum(r, t(r));
Phase2_Input_Const(i)..   Sum(j, x(j, i) * Lambda(j)) + s(i) =e= Theta.l * x0(i);
Phase2_Output_Const(r)..   Sum(j, y(j, r) * Lambda(j)) - t(r) =e= y0(r);

* results including Reference Points will save in this file 
File CCR_Model /Envelopment_CCR_input_oriented_results.txt/ ;

Models CCR_Phase1 /Phase1_Objective,Phase1_Input_Const,Phase1_Output_Const/
       CCR_Phase2 /Phase2_Objective,Phase2_Input_Const,Phase2_Output_Const/;

Puttl CCR_Model 'DMU':10, 'Theta':12, 'w (s + t)':15, 'Reference Unit (I1, I2, I3, Y1)'//;
Put CCR_Model;

* Calculating Theta, w(slacks) and Reference points for each unit
Loop(l,
  Loop(i, x0(i) = x(l, i));
  Loop(r, y0(r) = y(l, r));

  Solve CCR_Phase1 Using LP Minimizing z;
  Solve CCR_Phase2 Using LP Maximizing w;

* Saving results to Envelopment_CCR_input_oriented_results.txt
  Put l.tl:10;
  if (CCR_Phase1.modelstat eq 1,
    Put z.l:7:5, w.l:15:5;
    
    if (1 - z.l < 0.00001,
      Put  "    Efficient Unit";
      if (w.l > 0.00001,
        Put " (Technically)";
      );
    else 
* Calculating X(input) of Reference Point
      I1 = z.l * x0('I1');
      I2 = z.l * x0('I2');
      I3 = z.l * x0('I3');

      Put '    (' I1:10:4 ', ' I2:10:4 ', ' I3:10:4 ', ' y0('O1'):6:1 ')';
    );

  elseif CCR_Phase1.modelstat eq 3,
    Put "    Unbounded";
  elseif CCR_Phase1.modelstat eq 4,
    Put "    Infeasible";
  );
  Put /;

);

Putclose;

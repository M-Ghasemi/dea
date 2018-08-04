******Mohammad Sadegh Ghasemi 965051511******
******Envelopment CCR (output oriented)******

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
Variables z, Phi;
Positive Variables Lambda(j);

* Phase 2 Variables
Variables w;
Positive Variables
  s(i)  "Input excess",
  t(r)  "Output shortfall";

* Temporary Scalar for calculating Reference Unit Y
Scalar TempY;

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
Phase1_Objective..  z =e= Phi;
Phase1_Input_Const(i)..   Sum(j, x(j, i) * Lambda(j)) =l= x0(i);
Phase1_Output_Const(r)..   Sum(j, y(j, r) * Lambda(j)) =g= Phi * y0(r);

* Phase 2 Equations
Phase2_Objective..  w =e= Sum(i, s(i)) + Sum(r, t(r));
Phase2_Input_Const(i)..   Sum(j, x(j, i) * Lambda(j)) + s(i) =e= x0(i);
Phase2_Output_Const(r)..   Sum(j, y(j, r) * Lambda(j)) - t(r) =e= Phi.l * y0(r);

* Results including Reference Points will save in this file 
File CCR_Model /Envelopment_CCR_output_oriented_results.txt/ ;

Models CCR_Phase1 /Phase1_Objective,Phase1_Input_Const,Phase1_Output_Const/
       CCR_Phase2 /Phase2_Objective,Phase2_Input_Const,Phase2_Output_Const/;

Puttl CCR_Model 'DMU':10, 'Phi':12, 'w (s + t)':15, 'Reference Unit (I1, I2, I3, Y1)'//;
Put CCR_Model;

* Calculating Phi, w(slacks) and Reference points for each unit
Loop(l,
  Loop(i, x0(i) = x(l, i));
  Loop(r, y0(r) = y(l, r));

  Solve CCR_Phase1 Using LP Maximizing z;
  Solve CCR_Phase2 Using LP Maximizing w;

* Saving results to Envelopment_CCR_output_oriented_results.txt
  Put l.tl:10;
  if (CCR_Phase1.modelstat eq 1,
    Put z.l:7:5, w.l:15:5;

    if (z.l - 1 < 0.00001,
      Put  "    Efficient Unit";
      if (w.l > 0.00001,
        Put " (Technically)";
      );
    else 
* Calculating Y(output) of Reference Point
      TempY = z.l * y0('O1');
      Put '    (' x0('I1'):7:1 ', ' x0('I2'):7:1 ', ' x0('I3'):7:1 ', ' TempY:6:1 ')';
    );

  elseif CCR_Phase1.modelstat eq 3,
    Put "    Unbounded";
  elseif CCR_Phase1.modelstat eq 4,
    Put "    Infeasible";
  );
  Put /;

);

Putclose;

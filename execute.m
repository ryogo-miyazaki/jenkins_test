% setup variable values_
test_input_ex1
test_output_ex1_false

% open the model
mdl = 'test_model';
open_system(mdl);



% set configuration parameters
set_param(mdl, 'SolverName', 'FixedStepDiscrete');
set_param(mdl, 'FixedStep', num2str(0.01));
set_param(mdl, 'StopTime', '50');
set_param(mdl, 'LoadExternalInput', 'on');
set_param(mdl, 'ExternalInput', 'test_input');
set_param(mdl, 'SaveOutput', 'on');
set_param(mdl, 'SaveFormat', 'Dataset');
set_param(mdl, 'ReturnWorkspaceOutputs', 'on');

% simulate the model
sim_out = sim(mdl);
yout = sim_out.get('yout');
test_actual = Simulink.SimulationData.Dataset;
test_actual = test_actual.addElement(yout.get(1), 'test_outdata1'); 
test_actual = test_actual.addElement(yout.get(2), 'test_outdata2');

% close simulation
close_system(mdl, 0);

% check in Inspecter(Simulink) for debug
run_id_expect = Simulink.sdi.createRun('Expect', 'vars', test_actual);

% run_id_expect = Simulink.sdi.createRun('Expect', 'vars', test_expect);
run_id_actual = Simulink.sdi.createRun('Actual', 'vars', test_actual);

% compare the result datas
difference = Simulink.sdi.compareRuns(run_id_actual, run_id_expect);

% make the compared file (outputs and expect datas) 
metaDataOfInterest = [Simulink.sdi.SignalMetaData.Result, ...
                      Simulink.sdi.SignalMetaData.BlockPath1, ...
                      Simulink.sdi.SignalMetaData.RelTol, ...
                      Simulink.sdi.SignalMetaData.DataSource1, ...
                      Simulink.sdi.SignalMetaData.DataSource2,];

% Report on the run comparison
Simulink.sdi.report('ReportToCreate', 'Compare Runs', ...
                    'ReportOutputFolder', 'result_report', ...
                    'ReportOutputFile', 'test_model_report', ...
                    'PreventOverwritingFile', false, ...
                    'ColumnsToReport', metaDataOfInterest, ...
                    'ShortenBlockPath', false, ...
                    'LaunchReport', true, ...
                    'SignalsToReport', 'ReportAllSignals');

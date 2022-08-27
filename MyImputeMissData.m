function [info,params] = MyImputeMissData(varargin)
%% Random set-up
defaultStream = RandStream.getGlobalStream;

%% Parse inputs
p = inputParser;
p.addParamValue('State', defaultStream.State, @(x) true);
p.addParamValue('Soln', [], @(x) isempty(x) || isa(x,'ktensor') || isa(x,'ttensor'));
p.addParamValue('Type', 'CP', @(x) ismember(lower(x),{'cp','tucker'}));
p.addParamValue('Size', [10 10 10], @all);
p.addParamValue('Num_Factors', 2, @all);
p.addParamValue('Factor_Generator', 'randn', @is_valid_matrix_generator);
p.addParamValue('Lambda_Generator', 'rand', @is_valid_matrix_generator);
p.addParamValue('Core_Generator', 'randn', @is_valid_tensor_generator);
p.addParamValue('M', 0, @(x) is_missing_data(x) || (x == 0));
p.addParamValue('Sparse_M', false, @islogical);
p.addParamValue('Sparse_Generation', 0, @(x) x >= 0);
p.addParamValue('Symmetric', []);

p.parse(varargin{:});
params = p.Results;

info = struct;
info.Soln = generate_solution(params);
end
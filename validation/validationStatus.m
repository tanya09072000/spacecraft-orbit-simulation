function status = validationStatus(passed)
%VALIDATIONSTATUS Convert logical validation result to text.

if passed
    status = 'PASS';
else
    status = 'FAIL';
end

end
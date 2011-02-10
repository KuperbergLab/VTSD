function strMat = MakeRandomString(N,L,caseStr)


C = cell(1,N);


switch caseStr
    case 'upper'
        asciiInd = 65:90;
    case 'lower'
        asciiInd = 97:122;
    case 'mixed'
        asciiInd = [65:90 97:122];
end
for ii=1:N
    str = [];
    for jj=1:L
        % random letter, append
        randInd = 1 + floor((length(asciiInd)-1)*rand());
        str = [str asciiInd(randInd)];
    end
    % add to cell
    C{ii} = char(str);
end
strMat = char(C);
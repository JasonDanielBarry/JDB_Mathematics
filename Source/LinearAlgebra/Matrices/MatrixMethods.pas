unit MatrixMethods;

interface

    uses
        System.SysUtils, system.Types, system.math, system.Threading, system.Classes,
        LinearAlgebraTypes,
        MatrixHelperMethods,
        MatrixDeterminantMethods,
        VectorMethods
        ;

    //determinant
        function matrixDeterminant(const matrixIn : TLAMatrix) : double;

    //inverse
        function matrixInverse(const matrixIn : TLAMatrix) : TLAMatrix;

    //multiplication
        function matrixMultiplication(const matrix1In, matrix2In : TLAMatrix) : TLAMatrix; overload;
        function matrixMultiplication(  const matrixIn : TLAMatrix;
                                        const vectorIn : TLAVector  ) : TLAVector; overload;

    //solve linear equation system
        function solveLinearSystem( const coefficientmatrixIn   : TLAMatrix;
                                    const constantVectorIn      : TLAVector ) : TLAVector;

    //rotation matrix
        function rotationMatrix2D(const rotationAngleIn : double) : TLAMatrix;

        function rotationMatrix3D(const alphaIn, betaIn, gammaIn : double) : TLAMatrix;

    //transpose
        function matrixTranspose(const matrixIn : TLAMatrix) : TLAMatrix;

implementation

    //determinant
        function matrixDeterminant(const matrixIn : TLAMatrix) : double;
            begin
                result := MatrixDeterminantMethods.matrixDeterminant(matrixIn);
            end;

    //inverse
        //helper methods
            function cofactorMatrix(const matrixIn : TLAMatrix) : TLAMatrix;
                var
                    i, j        : integer;
                    C_ij        : double;
                    matrixSize  : TLAMatrixSize;
                    coFacMatOut : TLAMatrix;
                begin
                    if ( NOT(matrixIsSquare(matrixIn)) ) then
                        exit();

                    matrixSize := getMatrixSize(matrixIn);

                    coFacMatOut := newMatrix(matrixSize);

                    for i := 0 to (matrixSize.rows - 1) do
                        for j := 0 to (matrixSize.cols - 1) do
                            begin
                                C_ij := matrixEntryCofactor(i, j, matrixIn);

                                coFacMatOut[i][j] := C_ij;
                            end;

                    result := coFacMatOut;
                end;

            function matrixAdjoint(const matrixIn : TLAMatrix) : TLAMatrix;
                var
                    adjointMatrixOut,
                    coFacMat            : TLAMatrix;
                begin
                    coFacMat := cofactorMatrix(matrixIn);

                    adjointMatrixOut := matrixTranspose(coFacMat);

                    result := adjointMatrixOut;
                end;

        function matrixInverse(const matrixIn : TLAMatrix) : TLAMatrix;
            var
                matDet : double;
                matAdj,
                matInv : TLAMatrix;
            begin
                matDet := matrixDeterminant(matrixIn);

                if (abs(matDet) < 1e-3) then
                    exit();

                matAdj := matrixAdjoint(matrixIn);

                matInv := matrixScalarMultiplication(1 / matDet, matAdj);

                result := matInv;
            end;

    //multiplication
        //helper methods
            function getMatrixColumn(   const colIn     : integer;
                                        const matrixIn  : TLAMatrix ) : TLAVector;
                var
                    i, rowCount     : integer;
                    columnVectorOut : TLAVector;
                begin
                    rowCount := length(matrixIn);

                    SetLength(columnVectorOut, rowCount);

                    for i := 0 to (rowCount - 1) do
                        columnVectorOut[i] := matrixIn[i][colIn];

                    result := columnVectorOut;
                end;

            function getMatrixRow(  const rowIn     : integer;
                                    const matrixIn  : TLAMatrix ) : TLAVector;
                begin
                    result := matrixIn[rowIn];
                end;

        function matrixMultiplication(const matrix1In, matrix2In : TLAMatrix) : TLAMatrix;
            var
                r, c            : integer;
                vectorProduct   : double;
                size1, size2    : TLAMatrixSize;
                newMatrixOut    : TLAMatrix;
            function
                _matrixSizesAreCompatible() : boolean;
                    begin
                        //matrix1 must be m x r
                        //matrix2 must be r x n

                        size1 := getMatrixSize(matrix1In);
                        size2 := getMatrixSize(matrix2In);

                        _matrixSizesAreCompatible := (size1.cols = size2.rows);
                    end;
            function
                _multiplyRowAndColVectors(const rowIn, colIn : integer) : double;
                    var
                        colVector, rowVector : TLAVector;
                    begin
                        //row vector from matrix 1
                            rowVector := getMatrixRow(rowIn, matrix1In);

                        //column vector from matrix 2
                            colVector := getMatrixColumn(colIn, matrix2In);

                        _multiplyRowAndColVectors := vectorDotProduct(rowVector, colVector);
                    end;
            begin
                if ( NOT(_matrixSizesAreCompatible()) ) then
                    exit();

                newMatrixOut := newMatrix(size1.rows, size2.cols);

                for r := 0 to (size1.rows - 1) do
                    for c := 0 to (size2.cols - 1) do
                        begin
                            vectorProduct := _multiplyRowAndColVectors(r, c);

                            newMatrixOut[r][c] := vectorProduct;
                        end;

                result := newMatrixOut;
            end;

        function matrixMultiplication(  const matrixIn : TLAMatrix;
                                        const vectorIn : TLAVector  ) : TLAVector;
            var
                rowVectorMat,
                columnVectorMat,
                multMat         : TLAMatrix;
                vectorOut       : TLAVector;
            begin
                //convert the vector into a matrix (n x 1)
                    SetLength(rowVectorMat, 1);

                    rowVectorMat[0] := vectorIn;

                    columnVectorMat := matrixTranspose(rowVectorMat);

                //multiply the two matrices
                    multMat := matrixMultiplication(matrixIn, columnVectorMat);

                //convert the result of the matrix multiplication back to a vector
                    rowVectorMat := matrixTranspose(multMat);

                    vectorOut := rowVectorMat[0];

                result := vectorOut;
            end;

    //solve linear equation system
        function solveLinearSystem( const coefficientmatrixIn   : TLAMatrix;
                                    const constantVectorIn      : TLAVector ) : TLAVector;
            var
                detCoeffMat     : double;
                coeffInverse    : TLAMatrix;
                solutionVector  : TLAVector;
            begin
                //solution only exists if the coefficient matrix determinant is not zero
                    detCoeffMat := matrixDeterminant(coefficientmatrixIn);

                    if ( IsZero(detCoeffMat) ) then
                        exit();

                //Ax = b;
                //x := inv(A) * b
                    coeffInverse := matrixInverse(coefficientmatrixIn);

                    solutionVector := matrixMultiplication(coeffInverse, constantVectorIn);

                result := solutionVector;
            end;

    //rotation matrix
        function rotationMatrix2D(const rotationAngleIn : double) : TLAMatrix;
            var
                a                   : double;
                rotationMatrixOut   : TLAMatrix;
            begin
                //convert degrees to radians
                    a := DegToRad( rotationAngleIn );

                //set matrix size
                    setMatrixSize(2, 2, rotationMatrixOut);

                //populate rotation matrix
                    rotationMatrixOut[0][0] := cos(a);
                    rotationMatrixOut[0][1] := -sin(a);
                    rotationMatrixOut[1][0] := sin(a);
                    rotationMatrixOut[1][1] := cos(a);

                result := rotationMatrixOut;
            end;

        function rotationMatrix3D(const alphaIn, betaIn, gammaIn : double) : TLAMatrix;
            var
                a, b, g             : double;
                rotationMatrixOut   : TLAMatrix;
            begin
                //convert degrees to radians
                    a := DegToRad(  alphaIn  );
                    b := DegToRad(  betaIn   );
                    g := DegToRad(  gammaIn  );

                //set matrix size
                    setMatrixSize(3, 3, rotationMatrixOut);

                //populate rotation matrix
                    rotationMatrixOut[0][0] := cos(b) * cos(g);
                    rotationMatrixOut[0][1] := sin(a) * sin(b) * cos(g) - cos(a) * sin(g);
                    rotationMatrixOut[0][2] := cos(a) * sin(b) * cos(g) + sin(a) * sin(g);

                    rotationMatrixOut[1][0] := cos(b) * sin(g);
                    rotationMatrixOut[1][1] := sin(a) * sin(b) * sin(g) + cos(a) * cos(g);
                    rotationMatrixOut[1][2] := cos(a) * sin(b) * sin(g) - sin(a) * cos(g);

                    rotationMatrixOut[2][0] := -sin(b);
                    rotationMatrixOut[2][1] := sin(a) * cos(b);
                    rotationMatrixOut[2][2] := cos(a) * cos(b);

                result := rotationMatrixOut;
            end;

    //transpose
        function matrixTranspose(const matrixIn : TLAMatrix) : TLAMatrix;
            var
                r, c                : integer;
                matrixSize          : TLAMatrixSize;
                transposedMatrixOut : TLAMatrix;
            begin
                matrixSize := getMatrixSize(matrixIn);

                transposedMatrixOut := newMatrix(matrixSize.cols, matrixSize.rows);

                for r := 0 to (matrixSize.rows - 1) do
                    for c := 0 to (matrixSize.cols - 1) do
                        transposedMatrixOut[c][r] := matrixIn[r][c];

                result := transposedMatrixOut;
            end;


end.

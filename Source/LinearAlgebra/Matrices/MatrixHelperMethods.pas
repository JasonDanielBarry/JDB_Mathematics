unit MatrixHelperMethods;

interface

    uses
        System.SysUtils, system.Types, system.math,
        LinearAlgebraTypes,
        VectorMethods
        ;

    //get a matrix size
        function getMatrixSize(const matrixIn : TLAMatrix) : TLAMatrixSize;

    //test if a matrix is square
        function matrixIsSquare(const matrixIn : TLAMatrix) : boolean;

    //set a matrix size
        procedure setMatrixSize(const newRowCountIn, newColCountIn  : integer;
                                var matrixInOut                     : TLAMatrix); overload;

        procedure setMatrixSize(const newSizeIn : TLAMatrixSize;
                                var matrixInOut : TLAMatrix     ); overload;

    //create a new matrix with a set size
        function newMatrix(rowCountIn, colCountIn : integer) : TLAMatrix; overload;

        function newMatrix(const newSizeIn : TLAMatrixSize) : TLAMatrix; overload;

    //copy a matrix
        procedure matrixCopy(   const readMatrixIn      : TLAMatrix;
                                var writeMatrixInOut    : TLAMatrix );

    //test for equality
        function matricesEqual(matrix1In, matrix2In : TLAMatrix) : boolean;

    //multiply a matrix by a scalar
        function matrixScalarMultiplication(const scalarIn : double;
                                            const matrixIn      : TLAMatrix) : TLAMatrix;

    //test if 2 matrices are the same size
        function matricesAreSameSize(const matrix1In, matrix2In : TLAMatrix) : boolean;

implementation

    //get a matrix size
        function getMatrixSize(const matrixIn : TLAMatrix) : TLAMatrixSize;
            var
                r,
                rowCount, colCount  : integer;
                matrixDimensionsOut : TLAMatrixSize;
            begin
                rowCount := length(matrixIn);
                colCount := length(matrixIn[0]);

                for r := 1 to (rowCount - 1) do
                    if (length(matrixIn[r]) <> colCount) then
                        begin
                            colCount := -1;
                            exit();
                        end;

                matrixDimensionsOut.rows := rowCount;
                matrixDimensionsOut.cols := colCount;

                result := matrixDimensionsOut;
            end;

    //test if a matrix is square
        function matrixIsSquare(const matrixIn : TLAMatrix) : boolean;
            var
                matrixDimensions : TLAMatrixSize;
            begin
                matrixDimensions := getMatrixSize(matrixIn);

                result := matrixDimensions.isSquare();
            end;

    //set a matrix size
        procedure setMatrixSize(const newRowCountIn, newColCountIn  : integer;
                                var matrixInOut                     : TLAMatrix); overload;
            var
                r : integer;
            begin
                SetLength(matrixInOut, newRowCountIn);

                for r := 0 to (newRowCountIn - 1) do
                    SetLength(matrixInOut[r], newColCountIn);
            end;

        procedure setMatrixSize(const newSizeIn : TLAMatrixSize;
                                var matrixInOut : TLAMatrix     ); overload;
            begin
                setMatrixSize(newSizeIn.rows, newSizeIn.cols, matrixInOut);
            end;

    //create a new matrix with a set size
        function newMatrix(rowCountIn, colCountIn : integer) : TLAMatrix; overload;
            var
                matrixOut : TLAMatrix;
            begin
                setMatrixSize(rowCountIn, colCountIn, matrixOut);

                result := matrixOut;
            end;

        function newMatrix(const newSizeIn : TLAMatrixSize) : TLAMatrix; overload;
            begin
                result := newMatrix(newSizeIn.rows, newSizeIn.cols);
            end;

    //copy a matrix
        procedure matrixCopy(   const readMatrixIn      : TLAMatrix;
                                var writeMatrixInOut    : TLAMatrix );
            var
                c, r        : integer;
                matrixSize  : TLAMatrixSize;
            begin
                matrixSize := getMatrixSize(readMatrixIn);

                setMatrixSize(  matrixSize.rows, matrixSize.cols,
                                writeMatrixInOut                    );

                for r := 0 to (matrixSize.rows - 1) do
                    for c := 0 to (matrixSize.cols - 1) do
                        writeMatrixInOut[r][c] := readMatrixIn[r][c];
            end;

    //test for equality
        function matricesEqual(matrix1In, matrix2In : TLAMatrix) : boolean;
            var
                r,      c       : integer;
                size1,  size2   : TLAMatrixSize;
            function
                _elementsAreEqual(const rowIn, colIn : integer) : boolean;
                    var
                        value1, value2 : double;
                    begin
                        value1 := matrix1In[rowIn][colIn];
                        value2 := matrix2In[rowIn][colIn];

                        result := SameValue(value1, value2, 1e-6);
                    end;
            begin
                //get sizes
                    size1 := getMatrixSize(matrix1In);
                    size2 := getMatrixSize(matrix2In);

                //if the sizes are not equal the matrices are not equal
                    if ( NOT(size1.isEqual(size2)) ) then
                        begin
                            result := False;
                            exit();
                        end;

                //test each eleement for equality
                    for r := 0 to (size1.rows - 1) do
                        for c := 0 to (size1.cols - 1) do
                            if ( NOT(_elementsAreEqual(r, c)) ) then
                                begin
                                    result := False;
                                    exit();
                                end;

                result := True;
            end;

    //multiply a matrix by a scalar
        function matrixScalarMultiplication(const scalarIn : double;
                                            const matrixIn      : TLAMatrix) : TLAMatrix;
            var
                c, r        : integer;
                matrixSize  : TLAMatrixSize;
                matrixOut   : TLAMatrix;
            begin
                matrixCopy(matrixIn, matrixOut);

                matrixSize := getMatrixSize(matrixIn);

                for r := 0 to (matrixSize.rows - 1) do
                    for c := 0 to (matrixSize.cols - 1) do
                        matrixOut[r, c] := scalarIn * matrixOut[r, c];

                result := matrixOut;
            end;

    //test if 2 matrices are the same size
        function matricesAreSameSize(const matrix1In, matrix2In : TLAMatrix) : boolean;
            var
                row,
                rowCount1,  rowCount2   : integer;
                rowVector1, rowVector2  : TLAVector;
            begin
                //the row count of both matrices must be equal
                    rowCount1 := length(matrix1In);
                    rowCount2 := Length(matrix2In);

                    if (rowCount1 <> rowCount2) then
                        begin
                            result := False;
                            exit();
                        end;

                //each column of both matrices must be equal in size
                    for row := 0 to (rowCount1 - 1) do
                        begin
                            rowVector1 := matrix1In[row];
                            rowVector2 := matrix2In[row];

                            if ( NOT(vectorsAreSameSize(rowVector1, rowVector2)) ) then
                                begin
                                    result := False;
                                    exit();
                                end;
                        end;

                result := True;
            end;


end.

unit TEST_LAMatrixMethods;

interface

    uses
        system.SysUtils,
        DUnitX.TestFramework;

    type
      [TestFixture]
      TTestMatrixMethods = class
      public
        // Simple single Test
        [Test]
        procedure TestDeterminantAndInverse();
        [Test]
        procedure TestMatrixMultiplication();
        // Test with TestCase Attribute to supply parameters.
      end;

implementation

    uses
        LinearAlgebraTypes,
        LAMatrixHelperMethods,
        LAMatrixDeterminantMethods,
        LAMatrixMethods,
        LAVectorMethods;

    procedure TTestMatrixMethods.TestDeterminantAndInverse();
        var
            matDet, invDet          : double;
            testMatrix, inverseMat  : TLAMatrix;
        begin
            //2 x 2
                testMatrix := [ [1, 2],
                                [3, 4]  ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);

                Assert.AreEqual(invDet, 1 / matDet, 1e-3);

            //3 x 3
                testMatrix := [ [1, 8, 5],
                                [6, 4, 2],
                                [9, 7, 3]   ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);

                Assert.AreEqual(invDet, 1 / matDet, 1e-3);

            //4 x 4
                testMatrix := [ [ 1,  5, 16, 11],
                                [ 3, 14, 12, 10],
                                [ 9, 10, 11, 12],
                                [13, 14, 15, 16]    ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);

                Assert.AreEqual(invDet, 1 / matDet, 1e-3);

            //5 x 5
                testMatrix := [ [10, 16, 22, 21, 11],
                                [ 1, 11, 12, 16, 11],
                                [11, 16,  7,  1, 23],
                                [13,  8,  0, 24,  4],
                                [10, 12,  4, 14, 13]    ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);
                Assert.AreEqual(invDet, 1 / matDet, 1e-3);

            //6 x 6
                testMatrix := [ [ 5,  9, 31,  5, 22,  8],
                                [30, 34, 28, 24, 24, 26],
                                [11, 11, 19, 13, 26,  3],
                                [ 6, 11,  9, 10, 15, 26],
                                [14, 12,  2, 26, 30, 19],
                                [36, 15,  3, 14, 13, 14]    ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);
                Assert.AreEqual(invDet, 1 / matDet, 1e-3);

            //zero in first entry
                testMatrix := [ [ 0,  9, 31,  5, 22,  8],
                                [30, 34, 28, 24, 24, 26],
                                [11, 11, 19, 13, 26,  3],
                                [ 6, 11,  9, 10, 15, 26],
                                [14, 12,  2, 26, 30, 19],
                                [36, 15,  3, 14, 13, 14]    ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);
                Assert.AreEqual(invDet, 1 / matDet, 1e-3);

            //7 x 7
                testMatrix := [ [ 5,  9, 31,  5, 22,  8, 48],
                                [30, 34, 28, 24, 24, 26, 42],
                                [11, 11, 19, 13, 26,  3,  7],
                                [ 6, 11,  9, 10, 15, 26, 12],
                                [14, 12,  2, 26, 30, 19, 12],
                                [36, 15,  3, 14, 13, 14, 13],
                                [18, 11,  9, 29, 14, 47, 29]    ];

                matDet := matrixDeterminant(testMatrix);
                inverseMat := matrixInverse(testMatrix);
                invDet := matrixDeterminant(inverseMat);
                Assert.AreEqual(invDet, 1 / matDet, 1e-3);
        end;

    procedure TTestMatrixMethods.TestMatrixMultiplication();
        var
            matrix1, matrix2, multMat, expectedMat  : TLAMatrix;
            vector, resultVector, expectedVector    : TLAVector;
        begin
            matrix1 :=  [
                            [1, 2, 3, 4],
                            [2, 3, 4, 5],
                            [3, 4, 5, 6]
                        ];

            matrix2 :=  [
                            [1, 2, 3],
                            [2, 3, 4],
                            [3, 4, 5],
                            [4, 5, 6]
                        ];

            multMat := matrixMultiplication(matrix1, matrix2);

            expectedMat :=  [
                                [30, 40, 50],
                                [40, 54, 68],
                                [50, 68, 86]
                            ];

            Assert.IsTrue( matricesEqual(multMat, expectedMat) );

            //------------------------------------------------------------

            matrix1 :=  [
                            [1, 2, 3, 4, 5],
                            [2, 3, 4, 5, 6],
                            [3, 4, 5, 6, 7]
                        ];

            matrix2 :=  [
                            [1, 2, 3],
                            [2, 3, 4],
                            [3, 4, 5],
                            [4, 5, 6],
                            [5, 6, 7]
                        ];

            multMat := matrixMultiplication(matrix1, matrix2);

            expectedMat :=  [
                                [55,  70,  85],
                                [70,  90, 110],
                                [85, 110, 135]
                            ];

            Assert.IsTrue( matricesEqual(multMat, expectedMat) );

            //------------------------------------------------------------

            matrix1 :=  [
                            [1, 2, 3, 4, 5],
                            [2, 3, 4, 5, 6],
                            [3, 4, 5, 6, 7]
                        ];

            vector := [1, 2, 3, 4, 5];

            resultVector := matrixMultiplication(matrix1, vector);

            expectedVector := [55, 70, 85];

            Assert.IsTrue( vectorsEqual(resultVector, expectedVector) );
        end;

initialization

    TDUnitX.RegisterTestFixture(TTestMatrixMethods);

end.

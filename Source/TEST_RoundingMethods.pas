unit TEST_RoundingMethods;

interface

    uses
        system.SysUtils, System.Math,
        DUnitX.TestFramework;

    type
      [TestFixture]
      TTestRoundingMethods = class
      public
        // Simple single Test
        [TestCase('RoundToBaseMultiple 1 ', '23.5, 5, rmDown,     20', ',', True)]
        [TestCase('RoundToBaseMultiple 2 ', '23.0, 5, rmTruncate, 20', ',', True)]
        [TestCase('RoundToBaseMultiple 3 ', '22.5, 5, rmNearest,  20', ',', True)]
        [TestCase('RoundToBaseMultiple 3 ', '22.6, 5, rmNearest,  25', ',', True)]
        [TestCase('RoundToBaseMultiple 4 ', '21.0, 5, rmUp,       25', ',', True)]

        [TestCase('RoundToBaseMultiple 5 ', '20.25, 3, rmDown,     18', ',', True)]
        [TestCase('RoundToBaseMultiple 6 ', '22.75, 3, rmTruncate, 21', ',', True)]
        [TestCase('RoundToBaseMultiple 7 ', '19.00, 3, rmNearest,  18', ',', True)]
        [TestCase('RoundToBaseMultiple 8 ', '18.50, 3, rmUp,       21', ',', True)]

        [TestCase('RoundToBaseMultiple 9 ', '17.15, 1.5, rmDown,     16.5', ',', True)]
        [TestCase('RoundToBaseMultiple 10', '23.25, 4.5, rmTruncate, 22.5', ',', True)]
        [TestCase('RoundToBaseMultiple 11', '16.64, 3.5, rmNearest,  17.5', ',', True)]
        [TestCase('RoundToBaseMultiple 12', '13.79, 5.5, rmUp,       16.5', ',', True)]


        [TestCase('RoundToBaseMultiple 13', '37, 10,       rmDown,     30', ',', True)]
        [TestCase('RoundToBaseMultiple 14', '675, 100,     rmTruncate, 600', ',', True)]
        [TestCase('RoundToBaseMultiple 15', '1600, 1000,   rmNearest,  2000', ',', True)]
        [TestCase('RoundToBaseMultiple 16', '13000, 10000, rmUp,       20000', ',', True)]

        procedure TestRoundToBaseMultiple(  const valueIn, roundingBaseIn   : double;
                                            const roundingModeIn            : TRoundingMode;
                                            const expectedValueIn           : double        );
      end;

implementation

    uses
        RoundingMethods;

    procedure TTestRoundingMethods.TestRoundToBaseMultiple( const valueIn, roundingBaseIn   : double;
                                                            const roundingModeIn            : TRoundingMode;
                                                            const expectedValueIn           : double        );
        var
            actualValue : double;
        begin
            actualValue := RoundToBaseMultiple( valueIn, roundingBaseIn, roundingModeIn );

            Assert.AreEqual( actualValue, expectedValueIn, 1e-3 );
        end;

end.

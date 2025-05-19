unit GeomSpaceVectorClass;

interface

    //this class is a vector in R^n with its tail at the origin and head at <components>

    uses
        system.sysutils, system.Math,
        LinearAlgebraTypes,
        VectorMethods,
        GeometryTypes,
        GeometryBaseClass;

    type TGeomSpaceVector = class(TGeomBase)
        private
            const
                boundaryErrorMessage : string = 'Space Vector index out of bounds';
            var
                components : TLAVector;
            //set component
                procedure setComponent( dimensionIndexIn        : integer;
                                        const componentValueIn  : double);
            //get component
                function getComponent(dimensionIndexIn : integer) : double;
            //deep copy
                function copySelf() : TGeomSpaceVector;
        protected
            //
        public
            //constructor
                constructor create();
            //destructor
                destructor destroy(); override;
            //dimension manipulation
                //set dimensions
                    procedure setDimensions(dimensionCountIn : integer);
                //get dimensions
                    function dimensions() : integer;
                //add component
                    procedure addComponent(componentValueIn : double);
            //length manipulation
                //calculate vector length
                    function normalise() : double;
                //stretch the vector by a factor
                    procedure stretch(factorIn : double);
                //set the vector length
                    procedure setVectorLength(lengthIn : double);
            //unit vector
                //convert self into a unit vector
                    procedure unitVector();
                //return a unit vector
                    function calculateUnitVector() : TGeomSpaceVector;
            //component property
                property component[dimensionIndexIn : integer] : double read getComponent write setComponent; default;
    end;

implementation

    //private
        //set component
            procedure TGeomSpaceVector.setComponent(dimensionIndexIn        : integer;
                                                    const componentValueIn  : double);
                begin
                    try
                        components[dimensionIndexIn] := componentValueIn;
                    except
                        raise Exception.Create(boundaryErrorMessage);
                    end;
                end;

        //get component
            function TGeomSpaceVector.getComponent(dimensionIndexIn : integer) : double;
                begin
                    try
                        result := components[dimensionIndexIn];
                    except
                        raise Exception.Create(boundaryErrorMessage);
                    end;
                end;

        //deep copy
            function TGeomSpaceVector.copySelf() : TGeomSpaceVector;
                var
                    i           : integer;
                    newVector   : TGeomSpaceVector;
                begin
                    newVector := TGeomSpaceVector.create();

                    for i := 0 to (dimensions() - 1) do
                        newVector.addComponent(self[i]);

                    result := newVector;
                end;

    //protected

    //public
        //constructor
            constructor TGeomSpaceVector.create();
                begin
                    inherited create();

                    setDimensions(0);
                end;

        //destructor
            destructor TGeomSpaceVector.destroy();
                begin
                    inherited Destroy();
                end;

        //length manipulation
            //set dimensions
                procedure TGeomSpaceVector.setDimensions(dimensionCountIn : integer);
                    begin
                        SetLength(components, dimensionCountIn);
                    end;

            //get dimensions
                function TGeomSpaceVector.dimensions() : integer;
                    begin
                        result := length(components);
                    end;

            //add component
                procedure TGeomSpaceVector.addComponent(componentValueIn : double);
                    begin
                        setDimensions(dimensions + 1);

                        self[dimensions() - 1] := componentValueIn;
                    end;

        //length manipulation
            //calculate vector length
                function TGeomSpaceVector.normalise() : double;
                    begin
                        result := Norm( components );
                    end;

            //stretch the vector by a factor
                procedure TGeomSpaceVector.stretch(factorIn : double);
                    var
                        i : integer;
                    begin
                        for i := 0 to (dimensions() - 1) do
                            self[i] := self[i] * factorIn;
                    end;

            //set the vector length
                procedure TGeomSpaceVector.setVectorLength(lengthIn : double);
                    begin
                        unitVector();

                        stretch(lengthIn);
                    end;

        //unit vector
            //convert self into a unit vector
                procedure TGeomSpaceVector.unitVector();
                    var
                        newUnitVector : TLAVector;
                    begin
                        newUnitVector := vectorUnitVector( components );

                        copyVector( newUnitVector, components );
                    end;

            //return a unit vector
                function TGeomSpaceVector.calculateUnitVector() : TGeomSpaceVector;
                    var
                        vectorOut : TGeomSpaceVector;
                    begin
                        vectorOut := copySelf();

                        vectorOut.unitVector();

                        result := vectorOut;
                    end;

end.

#include "Shep2d.h"

Shep2d::Shep2d(void)
{
}

Shep2d::Shep2d(std::vector<Point> &pts, Cell_Face face)
{
  // initialize errors
  this->shep_error_string.clear();
  this->shep_error = false;

  // Dimension 2
  this->M = 2;
  this->NT = (this->M+1) * (this->M+2)/2;
  int LWS = this->NT * this->NT;

   // define arrays
   this->IW = new int*[this->M+1];        // integer work space array >= 5*M
   if(!this->IW)
   {
     std::cerr << "IW array not allocated\n";
     shep_error_string.append("IW array not allocated\n");
     this->shep_error = true;
   }

   int i;
   for(i = 1; i < this->M + 1; i++)
   {
     this->IW[i] = new int[6];
     if(!this->IW[i])
     {
       std::cerr << "IW array not allocated\n";
       shep_error_string.append("IW array not allocated\n");
       this->shep_error = true;
     }
   }

   this->WS = new double[LWS+1];     // float work space array >= NT**2
   if(!this->WS){
     std::cerr << "WS array not allocated\n";
     shep_error_string.append("WS array not allocated\n");
     this->shep_error = true;
   }

   for(i = 0; i < LWS + 1; i++)
   {
     this->WS[i] = 0.0;
   }

   this->XMIN = new double[this->M+1];     // array of min. nodal coordinates
   if(!this->XMIN)
   {
     std::cerr << "XMIN array not allocated\n";
     shep_error_string.append("XMIN array not allocated\n");
     this->shep_error = true;
   }

   this->DX = new double[this->M +1 ];       // array of min. cell dimensions
   if(!this->DX)
   {
     std::cerr << "DX array not allocated\n";
     shep_error_string.append("DX array not allocated\n");
     this->shep_error = true;
   }

   this->N = pts.size();

   // restrictions on number of points
   if((this->N < this->NT)||(this->N > NMAX)){
     std::cerr << "       *** ERROR -- N = " << N << "  MAXIMUM VALUE = " << NMAX << " ***" << std::endl;
     shep_error_string.append("N out of range NT to NMAX\n");

     this->shep_error = true;
   }

   // allocate array for cartesian coordinates of known nodes
   this->X = new double*[(this->M) + 2];
   if(!this->X){
     std::cerr << "X array not allocated\n";
     shep_error_string.append("X array not allocated\n");
     this->shep_error = true;
   }
   X[0] = NULL;
   for(i = 1; i < this->M + 2; i++)
   {
     this->X[i] = new double[this->N+1];
     if(!this->X[i])
     {
       std::cerr << "X array not allocated\n";
       shep_error_string.append("X array not allocated\n");
       this->shep_error = true;
     }
   }

   // Store in X and W
   int j;
   int iface = (int) face;

   for(i = 1;i < this->N+1; i++)
   {
     int icoord = 0;
     for(j=0; j < 3; j++)
     {
       if (j != iface) 
       {
	 X[icoord + 1][i] = pts[i - 1].get_coord()[j];
	 icoord++;
       }
     } 
     this->W[i] = pts[i - 1].get_v();  // known node stored in W
   }
   
   // allocate array A, size = N*(NT-1)
   this->A = new double*[this->N+1];
   if(!this->A)
   {
     std::cerr << "A array not allocated\n";
     shep_error_string.append("A array not allocated\n");
     this->shep_error = true;
   }
    
   for(i = 1; i < this->N + 1; i++){
     this->A[i] = new double[this->NT];
     if(!this->A[i]){
       std::cerr << "A array not allocated\n";
       shep_error_string.append("A array not allocated\n");
       this->shep_error = true;
      }
    }

   for(i = 1; i < this->N + 1; i++)
   {
    for(j = 1; j < NT; j++)
    {
       this->A[i][j] = 0;
    }
   }

   int NWMAX = MIN0(50,N-1);
   
   // values for input parameters for NQ, NW, and NR - check if legit.
   this->NQ = 17;
   if (this->NQ > NWMAX || this->NQ < NT - 1)
   {
     if (NT - 1 < NWMAX)
     {
       this->NQ = (NT - 1 + NWMAX) / 2;
     } else
     {
       std::cerr << "Could not set NQ" << std::endl;
       shep_error_string.append("Could not set NQ\n");
       this->shep_error = true;
     }
   }

   this->NW = 32;
   if (this->NW > NWMAX) 
   {
      this->NW = NWMAX / 2;
   }

   this->NR = (int) pow((double) (this->N)/3., (double) 1.0/this->M);
   if (this->NR < 1 || this->NR > NRMAX)
   {
     this->NR = 1;
   }
   if (this->NR < 1 || this->NR > NRMAX)
   {
       std::cerr << "Could not set NR" << std::endl;
       shep_error_string.append("Could not set NR\n");
       this->shep_error = true;
   }

   // Interpolate surface
   int IER;
   
   this->QSHEPM(IER);


   // check IER to determine if QSHEPM completed OK.  If not, print out
   // reasons and exit the program.
   if(IER != 0 ){
     if( IER == 2){
       std::cerr << "   *** ERROR IN QSHEPM -- DUPLICATE NODES ENDOUNTERED ***\n";
       shep_error_string.append("Duplicate nodes\n");
     } else
     {
       if( IER == 3)
       {
	 std::cerr << "   *** ERROR IN QSHEPM -- ALL NODES ARE COPLANAR ***\n";
	 shep_error_string.append("Coplanar nodes\n");
       }
     }
     this->shep_error = true;
   }
}
Shep2d::~Shep2d(void)
{
}

double Shep2d::Evaluate(Point pt, Cell_Face face)
{
  double P[3];
  int i;

  int icoord = 1; 
  for (i = 0; i < 3; i++)
  {
    if (i != (int) face)
    {
      P[icoord++] = pt.get_coord()[i];
    }
  }
  return (this->QSMVAL(P));
}

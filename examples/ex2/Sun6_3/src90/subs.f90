!       ******************************************************
!      *                                                      *
!      *                  SUBROUTINE EXERFC                   *
!      *                                                      *
!      *            VERSION CURRENT AS OF 10/01/87            *
!      *                                                      *
!       ******************************************************
!
      SUBROUTINE EXERFC (X,YY,Z)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(5),Q1(5),P2(9),Q2(9),P3(6),Q3(6)
!
!       THIS ROUTINE USES RATIONAL CHEBYSHEV APPROXIMATIONS
!       FOR EVALUATING THE ERROR FUNCTION AND COMPLEMENTARY
!       ERROR FUNCTION IN ORDER TO EVALUATE THE PRODUCT OF
!       EXP(X) AND ERFC(Y)
!
      DATA P1/3.209377589138469472562D03,3.774852376853020208137D02, &
             1.138641541510501556495D02,3.161123743870565596947D0,   &
             1.857777061846031526730D-01/
      DATA Q1/2.844236833439170622273D03,1.282616526077372275645D03, &
             2.440246379344441733056D02,2.360129095234412093499D01,  &
             1.0D0 /
      DATA P2/1.23033935479799725272D03,2.05107837782607146532D03,   &
             1.71204761263407058314D03,8.81952221241769090411D02,    &
             2.98635138197400131132D02,6.61191906371416294775D01,    &
            8.88314979438837594118D00,5.64188496988670089180D-01,    &
            2.15311535474403846343D-08/
      DATA Q2/1.23033935480374942043D03,3.43936767414372163696D03,   &
             4.36261909014324715820D03,3.29079923573345962678D03,    &
             1.62138957456669018874D03,5.37181101862009857509D02,    &
             1.17693950891312499305D02,1.57449261107098347253D01,    &
             1.0D0 /
      DATA P3/-6.58749161529837803157D-04,-1.60837851487422766278D-02, &
             -1.25781726111229246204D-01,-3.60344899949804439429D-01,  &
             -3.05326634961232344035D-01,-1.63153871373020978498D-02/  
      DATA Q3/2.33520497626869185443D-03,6.05183413124413191178D-02,   &
             5.27905102951428412248D-01,1.87295284992346047209D00,     &
             2.56852019228982242072D00,1.0D0/
!
      IF(YY.EQ.0.0D0) Z=DEXP(X)
      IF(YY.EQ.0.0D0) RETURN
      Y=DABS(YY)
!
!        FOR 0.0 < Y < .46875
      IF (Y.GT.0.46875D0) GO TO 20
      SUMP=0.0D0
      SUMQ=0.0D0
      DO 10 I=1,5
      Y2I=Y**(2*(I-1))
      SUMP=SUMP+P1(I)*Y2I
      SUMQ=SUMQ+Q1(I)*Y2I
10    CONTINUE
      ERF=Y*SUMP/SUMQ
      IF(YY.LT.0.0) ERF=-ERF
      ERFCY=1.0D0-ERF
      Z=DEXP(X)*ERFCY
      RETURN
!
!        FOR 0.0 < Y < .46875
20    IF (Y.GT.4.0D0) GO TO 40
      SUMP=0.0D0
      SUMQ=0.0D0
      DO 30 I=1,9
      YI=Y**(I-1)
      SUMP=SUMP+P2(I)*YI
      SUMQ=SUMQ+Q2(I)*YI
30    CONTINUE
      Z=DEXP(X-Y*Y)*SUMP/SUMQ
      IF(YY.LT.0.0D0) Z=2.0D0*DEXP(X)-Z
      RETURN
40    SUMP=0.0D0
      SUMQ=0.0D0
      DO 50 I=1,6
      Y2I=Y**(-2*(I-1))
      SUMP=SUMP+P3(I)*Y2I
      SUMQ=SUMQ+Q3(I)*Y2I
50    CONTINUE
      SQRTPI=0.5641895835477562869481D0
      Z=SQRTPI+SUMP/(Y*Y*SUMQ)
      Z=DEXP(X-Y*Y)*Z/Y
      IF(YY.LT.0.0D0) Z=2.0D0*DEXP(X)-Z
      RETURN
      END
!
!       ******************************************************
!      *                                                      *
!      *                  SUBROUTINE GLQPTS                   *
!      *                                                      *
!      *            VERSION CURRENT AS OF 10/01/87            *
!      *                                                      *
!       ******************************************************
!
      SUBROUTINE GLQPTS (N)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      CHARACTER*1 SKIP
      COMMON /GLPTS/ WN(256),ZN(256)
      COMMON /IOUNIT/ IN,IO
!
!       THIS ROUTINE READS THE NORMALIZED ROOTS ZN(I) AND WEIGHTS WN(I)
!       OF THE LEGENDRE POLYNOMIALS FROM THE DATA FILE 'glq.pts'
!
!       N IS THE NUMBER OF INTEGRATION POINTS AND CAN ONLY HAVE A
!       VALUE OF EITHER 4,20,60,104,OR 256
!
      IN2=77
      OPEN(IN2,FILE='glq.pts',STATUS='OLD')
!
!       SKIP LINES IN FILE UNTIL CORRECT COEFFICIENTS ARE REACHED
      ISKIP=-1
      IF(N.EQ.4) ISKIP=7
      IF(N.EQ.20) ISKIP=9
      IF(N.EQ.60) ISKIP=15
      IF(N.EQ.104) ISKIP=31
      IF(N.EQ.256) ISKIP=57
      IF (ISKIP.EQ.-1) WRITE(IO,201)
      IF (ISKIP.EQ.-1) STOP
      DO 60 I=1,ISKIP
60    READ(IN2,101) SKIP
!
!       READ IN ZN(I) AND WN(I), FOUR VALUES PER LINE
      NC=N/8
      IF (MOD(N,8).NE.0) NC=NC+1
      DO 80 I=1,NC
      K=(I-1)*8-1
      READ(IN2,102) (ZN(K+J*2),J=1,4)
80    CONTINUE
      DO 100 I=1,NC
      K=(I-1)*8-1
      READ(IN2,102) (WN(K+J*2),J=1,4)
100   CONTINUE
!
!       FILL IN THE SYMMETRIC TERMS
      DO 120 J=2,N,2
      J1=J-1
      ZN(J)=-ZN(J1)
120   WN(J)=WN(J1)
      CLOSE(IN2)
      RETURN
!
!       FORMAT STATEMENTS
101   FORMAT(A1)
102   FORMAT(4D20.0)
201   FORMAT(TR20,'*****  ERROR IN ROUTINE GLQPTS  *****'/ &
        TR20,'NO. OF ROOTS SPECIFIED MUST EQUAL 4,20,60,104 OR 256')
      END
!
!       ******************************************************
!      *                                                      *
!      *                  SUBROUTINE WTITLE                   *
!      *                                                      *
!      *            VERSION CURRENT AS OF 10/01/87            *
!      *                                                      *
!       ******************************************************
!
       SUBROUTINE WTITLE
       CHARACTER*1 LINE1(60),EQUAL,BLANK
       CHARACTER DATE*16,TIME*8
       CHARACTER*60 LINE
       CHARACTER*61 T1
       CHARACTER*80 TITLE
       COMMON/CSCH/TITLE
       COMMON /IOUNIT/ IN,IO
       DATA EQUAL/'='/,BLANK/' '/,DATE/'                 '/, &
           TIME/'        '/
!
!        THIS ROUTINE CREATES A TITLE BOX ON THE FIRST PAGE OF
!        PROGRAM OUTPUT. THE ROUTINE READS AND PRINTS ALL DATA
!        CARDS UNTIL IT ENCOUNTERS AN '=' IN COLUMN 1. THE FIRST 1
!        LINES READ IN ARE ALSO USED AS TITLES ON PLOTS.
!
       WRITE(IO,201)
       DO 10 L=1,60
       READ(IN,101,END=20) LINE
       IF (LINE(1:1).EQ.EQUAL) GOTO 60
       T1=LINE
!       STRIP OFF TRAILING BLANKS AND CENTER LINE
       DO 15 N=1,60
       NN=61-N
 15    IF(LINE(NN:NN).NE.BLANK) GOTO 20
 20    NN1=NN+1
       T1(NN1:NN1)='$'
       IF(L.LT.2) TITLE=T1
       NS=(60-NN)/2
       IF(NS.EQ.0) GO TO 35
       DO 30 I=1,60
 30    LINE1(I)=BLANK
 35    NS1=NS+1
       DO 40 I=1,NN
 40    LINE1(NS+I)=LINE(I:I)
 10    WRITE(IO,202) (LINE1(I),I=1,60)
 60    WRITE(IO,203) DATE,TIME
       RETURN
!
!       FORMAT STATEMENTS
 101   FORMAT (A60)
 201   FORMAT(//TR16,68(1H*))
 202   FORMAT(TR16,1H*,66X,1H*/TR16,1H*,3X,60A1,3X,1H*)
 203   FORMAT(TR16,1H*,66X,1H*/TR16,1H*,12X,'PROGRAM RUN ON ', &
         A16,' AT ',A8,11X,1H*/TR16,1H*,66X,1H*/TR16,68(1H*)     &
         /)
       END
!
!       ******************************************************
!      *                                                      *
!      *                  SUBROUTINE OFILE                    *
!      *                                                      *
!      *            VERSION CURRENT AS OF 10/01/87            *
!      *                                                      *
!       ******************************************************
!
      SUBROUTINE OFILE
      CHARACTER*14 IFNAME,OFNAME,NAME,FNAME
      CHARACTER*1 STAR
      COMMON /IOUNIT/ IN,IO
      DATA STAR/'*'/
      IN=15
      IO=16
      WRITE(*,5)
      !READ(*,7) IFNAME
      IFNAME = 'Sun6_3.dat'
      WRITE(*,6)
      !READ(*,7) NAME
      NAME = "Sun6_3"
	  !OFNAME='Out.'//NAME
      OFNAME=TRIM(NAME)//'.out'
      OPEN (IN,FILE=IFNAME,STATUS='OLD')
      IF(OFNAME(1:1).EQ.STAR) IO=1
      IF(OFNAME(1:1).NE.STAR) OPEN (IO,FILE=OFNAME)
	  FNAME=TRIM(NAME)//'.pmap'
	  OPEN(13,FILE=FNAME)
      RETURN
!
!       FORMAT STATEMENTS
5     FORMAT(5X,'Enter name of input file:')
6     FORMAT(5X,'Enter suffix for output files:')
7     FORMAT(A14)
      END

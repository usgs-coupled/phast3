pcf 
* control data 
restart estimation 
     17   227      2      0     1 
     2     1   single   point   1   0   0 
10.0  -3.0    0.3    0.03     -9  999  LAMFORGIVE DERFORGIVE 
0.2   2.0   1.0e-3 absparmax(1)=0.3
0.1  noaui 
30   .005  4   4  .005   4 
1    1    1  
* singular value decomposition 
1 
1 5e-7 
1 
* parameter groups 
chem         relative      1.00000E-02  0.0000    switch     2.0000      parabolic
trans        relative      1.00000E-02  0.0000    switch     2.0000      parabolic
* parameter data 
AnionOH2_k	fixed		absolute(1)	4.1		2.0		6.0		chem	1.0		0.0		1
AnionHPO4_k	fixed		absolute(1)	26.7		25.		30.0		chem	1.0		0.0		1
Anion_sites	fixed		factor		3450e-6		3450e-8		3450e-4		chem	1.0		0.0		1
CationOH2_k	fixed		absolute(1)	4.1		2.0		6.0		chem	1.0		0.0		1
Cation_k	fixed		absolute(1)	-1.8		-4.0		0.0		chem	1.0		0.0		1
Cation_sites	fixed		factor		18000e-6	23000e-8	23000e-4	chem	1.0		0.0		1
DO		fixed		factor		250.0		100.0		500.		chem	1.0		0.0		1
Remove_N2_k	fixed		factor		1.16e-7		1e-9		1e-5		chem	1.0		0.0		1
Effluent_P	fixed		factor		380.0		100.0		500.0		chem	1.0		0.0		1
Remove_P_k	none		factor		2.1e-8		1e-10		1e-5		chem	1.0		0.0		1
TOC		fixed		factor		1600.0		160.0		16000.0		chem	1.0		0.0		1
Decay_k		fixed		factor		1e-7		1e-9		1e-5		chem	1.0		0.0		1
SOC		fixed		factor		1000.0		10.0		10000.0		chem	1.0		0.0		1
Sorb_SOC_k	fixed		factor		1.16e-7		1e-9		1e-5		chem	1.0		0.0		1
React_SOC_k	fixed		factor		1.16e-7		1e-9		1e-5		chem	1.0		0.0		1
time_step	fixed		absolute(1)	0.25		0.0		0.25		trans	1.0		0.0		1
time_change	fixed		absolute(1)	1994		1994		2015		trans	1.0		0.0		1

* observation groups 
P

* observation data 
P_uM_1993_1     0.71400E+00    0.71400E-01             P
P_uM_1993_2     0.71400E+00    0.71400E-01             P
P_uM_1993_3     0.71400E+00    0.71400E-01             P
P_uM_1993_4     0.71400E+00    0.71400E-01             P
P_uM_1993_5     0.71400E+00    0.71400E-01             P
P_uM_1993_6     0.14290E+01    0.14290E+00             P
P_uM_1993_7     0.35710E+01    0.35710E+00             P
P_uM_1993_8     0.28570E+01    0.28570E+00             P
P_uM_1993_9     0.21430E+01    0.21430E+00             P
P_uM_1993_10     0.50000E+01    0.50000E+00             P
P_uM_1993_11     0.35710E+01    0.35710E+00             P
P_uM_1993_12     0.71400E+00    0.71400E-01             P
P_uM_1993_13     0.78571E+02    0.78571E+01             P
P_uM_1993_14     0.55000E+02    0.55000E+01             P
P_uM_1993_15     0.12857E+02    0.12857E+01             P
P_uM_1993_16     0.71430E+01    0.71430E+00             P
P_uM_1993_17     0.28570E+01    0.28570E+00             P
P_uM_1993_18     0.21430E+01    0.21430E+00             P
P_uM_1993_19     0.71429E+02    0.71429E+01             P
P_uM_1993_20     0.63571E+02    0.63571E+01             P
P_uM_1993_21     0.54286E+02    0.54286E+01             P
P_uM_1993_22     0.47143E+02    0.47143E+01             P
P_uM_1993_23     0.45714E+02    0.45714E+01             P
P_uM_1993_24     0.55000E+02    0.55000E+01             P
P_uM_1993_25     0.66429E+02    0.66429E+01             P
P_uM_1993_26     0.55000E+02    0.55000E+01             P
P_uM_1993_27     0.17857E+02    0.17857E+01             P
P_uM_1993_28     0.57140E+01    0.57140E+00             P
P_uM_1993_29     0.71430E+01    0.71430E+00             P
P_uM_1993_30     0.19286E+02    0.19286E+01             P
P_uM_1993_31     0.10714E+02    0.10714E+01             P
P_uM_1993_32     0.57140E+01    0.57140E+00             P
P_uM_1993_33     0.71430E+01    0.71430E+00             P
P_uM_1993_34     0.71400E+00    0.71400E-01             P
P_uM_1993_35     0.71400E+00    0.71400E-01             P
P_uM_1993_36     0.71400E+00    0.71400E-01             P
P_uM_1993_37     0.71400E+00    0.71400E-01             P
P_uM_1993_38     0.14290E+01    0.14290E+00             P
P_uM_1993_39     0.28570E+01    0.28570E+00             P
P_uM_1993_40     0.78571E+02    0.78571E+01             P
P_uM_1993_41     0.92857E+02    0.92857E+01             P
P_uM_1993_42     0.85714E+02    0.85714E+01             P
P_uM_1993_43     0.71429E+02    0.71429E+01             P
P_uM_1993_44     0.85714E+02    0.85714E+01             P
P_uM_1993_45     0.92857E+02    0.92857E+01             P
P_uM_1993_46     0.10000E+03    0.10000E+02             P
P_uM_1993_47     0.92857E+02    0.92857E+01             P
P_uM_1993_48     0.85714E+02    0.85714E+01             P
P_uM_1993_49     0.14290E+01    0.14290E+00             P
P_uM_1993_50     0.71400E+00    0.71400E-01             P
P_uM_1993_51     0.71400E+00    0.71400E-01             P
P_uM_1993_52     0.21430E+01    0.21430E+00             P
P_uM_1993_53     0.28570E+01    0.28570E+00             P
P_uM_1993_54     0.21430E+01    0.21430E+00             P
P_uM_1993_55     0.50000E+01    0.50000E+00             P
P_uM_1993_56     0.64290E+01    0.64290E+00             P
P_uM_1993_57     0.71430E+01    0.71430E+00             P
P_uM_1993_58     0.14286E+02    0.14286E+01             P
P_uM_1993_59     0.15000E+02    0.15000E+01             P
P_uM_1993_60     0.15000E+02    0.15000E+01             P
P_uM_1993_61     0.12143E+02    0.12143E+01             P
P_uM_1993_62     0.15714E+02    0.15714E+01             P
P_uM_1993_63     0.15000E+02    0.15000E+01             P
P_uM_1993_64     0.20000E+02    0.20000E+01             P
P_uM_1993_65     0.10714E+02    0.10714E+01             P
P_uM_1993_66     0.57140E+01    0.57140E+00             P
P_uM_1993_67     0.57140E+01    0.57140E+00             P
P_uM_1993_68     0.50000E+01    0.50000E+00             P
P_uM_1993_69     0.50000E+01    0.50000E+00             P
P_uM_1993_70     0.57140E+01    0.57140E+00             P
P_uM_1993_71     0.35710E+01    0.35710E+00             P
P_uM_1993_72     0.42860E+01    0.42860E+00             P
P_uM_1993_73     0.56429E+02    0.56429E+01             P
P_uM_1993_74     0.57140E+01    0.57140E+00             P
P_uM_1993_75     0.71400E+00    0.71400E-01             P
P_uM_1993_76     0.28570E+01    0.28570E+00             P
P_uM_1993_77     0.21430E+01    0.21430E+00             P
P_uM_1993_78     0.71400E+00    0.71400E-01             P
P_uM_1993_79     0.14290E+01    0.14290E+00             P
P_uM_1993_80     0.50000E+01    0.50000E+00             P
P_uM_1993_81     0.35714E+02    0.35714E+01             P
P_uM_1993_82     0.48571E+02    0.48571E+01             P
P_uM_1993_83     0.50714E+02    0.50714E+01             P
P_uM_1993_84     0.30714E+03    0.30714E+02             P
P_uM_1993_85     0.36429E+02    0.36429E+01             P
P_uM_1993_86     0.27857E+02    0.27857E+01             P
P_uM_1993_87     0.25000E+02    0.25000E+01             P
P_uM_1993_88     0.20714E+02    0.20714E+01             P
P_uM_1993_89     0.16429E+02    0.16429E+01             P
P_uM_1993_90     0.11429E+02    0.11429E+01             P
P_uM_1993_91     0.10000E+02    0.10000E+01             P
P_uM_1993_92     0.10000E+02    0.10000E+01             P
P_uM_1993_93     0.71400E+00    0.71400E-01             P
P_uM_1993_94     0.64290E+01    0.64290E+00             P
P_uM_1993_95     0.85714E+02    0.85714E+01             P
P_uM_1993_96     0.13571E+03    0.13571E+02             P
P_uM_1993_97     0.10714E+03    0.10714E+02             P
P_uM_1993_98     0.56429E+02    0.56429E+01             P
P_uM_1993_99     0.38571E+02    0.38571E+01             P
P_uM_1993_100     0.29286E+02    0.29286E+01             P
P_uM_1993_101     0.33571E+02    0.33571E+01             P
P_uM_1993_102     0.12857E+03    0.12857E+02             P
P_uM_1993_103     0.92857E+02    0.92857E+01             P
P_uM_1993_104     0.11429E+03    0.11429E+02             P
P_uM_1993_105     0.71429E+02    0.71429E+01             P
P_uM_1993_106     0.26429E+02    0.26429E+01             P
P_uM_1993_107     0.17143E+02    0.17143E+01             P
P_uM_1993_108     0.71400E+00    0.71400E-01             P
P_uM_1993_109     0.21430E+01    0.21430E+00             P
P_uM_1993_110     0.38571E+02    0.38571E+01             P
P_uM_1993_111     0.71430E+01    0.71430E+00             P
P_uM_1993_112     0.78571E+02    0.78571E+01             P
P_uM_1993_113     0.67143E+02    0.67143E+01             P
P_uM_1993_114     0.58571E+02    0.58571E+01             P
P_uM_1993_115     0.56429E+02    0.56429E+01             P
P_uM_1993_116     0.55714E+02    0.55714E+01             P
P_uM_1993_117     0.44286E+02    0.44286E+01             P
P_uM_1993_118     0.39286E+02    0.39286E+01             P
P_uM_1993_119     0.29286E+02    0.29286E+01             P
P_uM_1993_120     0.26429E+02    0.26429E+01             P
P_uM_1993_121     0.24286E+02    0.24286E+01             P
P_uM_1993_122     0.22857E+02    0.22857E+01             P
P_uM_1993_123     0.21429E+02    0.21429E+01             P
P_uM_1993_124     0.19286E+02    0.19286E+01             P
P_uM_1993_125     0.15000E+02    0.15000E+01             P
P_uM_1993_126     0.71430E+01    0.71430E+00             P
P_uM_1993_127     0.71400E+00    0.71400E-01             P
P_uM_1993_128     0.71400E+00    0.71400E-01             P
P_uM_1993_129     0.71400E+00    0.71400E-01             P
P_uM_1993_130     0.71400E+00    0.71400E-01             P
P_uM_1993_131     0.14290E+01    0.14290E+00             P
P_uM_1993_132     0.14290E+01    0.14290E+00             P
P_uM_1993_133     0.21430E+01    0.21430E+00             P
P_uM_1993_134     0.27857E+02    0.27857E+01             P
P_uM_1993_135     0.44286E+02    0.44286E+01             P
P_uM_1993_136     0.66429E+02    0.66429E+01             P
P_uM_1993_137     0.78571E+02    0.78571E+01             P
P_uM_1993_138     0.85714E+02    0.85714E+01             P
P_uM_1993_139     0.92857E+02    0.92857E+01             P
P_uM_1993_140     0.85714E+02    0.85714E+01             P
P_uM_1993_141     0.85714E+02    0.85714E+01             P
P_uM_1993_142     0.14290E+01    0.14290E+00             P
P_uM_1993_143     0.71400E+00    0.71400E-01             P
P_uM_1993_144     0.21430E+01    0.21430E+00             P
P_uM_1993_145     0.71400E+00    0.71400E-01             P
P_uM_1993_146     0.71400E+00    0.71400E-01             P
P_uM_1993_147     0.71400E+00    0.71400E-01             P
P_uM_1993_148     0.71400E+00    0.71400E-01             P
P_uM_1993_149     0.14290E+01    0.14290E+00             P
P_uM_1993_150     0.71400E+00    0.71400E-01             P
P_uM_1993_151     0.14290E+01    0.14290E+00             P
P_uM_1993_152     0.71400E+00    0.71400E-01             P
P_uM_1993_153     0.71400E+00    0.71400E-01             P
P_uM_1993_154     0.24286E+02    0.24286E+01             P
P_uM_1993_155     0.10000E+03    0.10000E+02             P
P_uM_1993_156     0.12143E+03    0.12143E+02             P
P_uM_1993_157     0.78571E+02    0.78571E+01             P
P_uM_1993_158     0.18571E+02    0.18571E+01             P
P_uM_1993_159     0.10714E+02    0.10714E+01             P
P_uM_1993_160     0.15000E+02    0.15000E+01             P
P_uM_1993_161     0.28570E+01    0.28570E+00             P
P_uM_1993_162     0.42860E+01    0.42860E+00             P
P_uM_1993_163     0.71400E+00    0.71400E-01             P
P_uM_1993_164     0.42860E+01    0.42860E+00             P
P_uM_1993_165     0.21430E+01    0.21430E+00             P
P_uM_1993_166     0.28570E+01    0.28570E+00             P
P_uM_1993_167     0.71400E+00    0.71400E-01             P
P_uM_1993_168     0.14290E+01    0.14290E+00             P
P_uM_1993_169     0.14290E+01    0.14290E+00             P
P_uM_1993_170     0.10000E+02    0.10000E+01             P
P_uM_1993_171     0.30714E+02    0.30714E+01             P
P_uM_1993_172     0.45714E+02    0.45714E+01             P
P_uM_1993_173     0.51429E+02    0.51429E+01             P
P_uM_1993_174     0.56429E+02    0.56429E+01             P
P_uM_1993_175     0.60000E+02    0.60000E+01             P
P_uM_1993_176     0.70714E+02    0.70714E+01             P
P_uM_1993_177     0.65000E+02    0.65000E+01             P
P_uM_1993_178     0.69286E+02    0.69286E+01             P
P_uM_1993_179     0.67857E+02    0.67857E+01             P
P_uM_1993_180     0.10714E+03    0.10714E+02             P
P_uM_1993_181     0.92857E+02    0.92857E+01             P
P_uM_1993_182     0.21430E+01    0.21430E+00             P
P_uM_1993_183     0.69286E+02    0.69286E+01             P
P_uM_1993_184     0.18571E+03    0.18571E+02             P
P_uM_1993_185     0.15000E+03    0.15000E+02             P
P_uM_1993_186     0.71429E+02    0.71429E+01             P
P_uM_1993_187     0.15714E+03    0.15714E+02             P
P_uM_1993_188     0.30000E+03    0.30000E+02             P
P_uM_1993_189     0.40000E+03    0.40000E+02             P
P_uM_1993_190     0.33571E+03    0.33571E+02             P
P_uM_1993_191     0.32143E+03    0.32143E+02             P
P_uM_1993_192     0.32143E+03    0.32143E+02             P
P_uM_1993_193     0.11429E+03    0.11429E+02             P
P_uM_1993_194     0.85714E+02    0.85714E+01             P
P_uM_1993_195     0.11429E+03    0.11429E+02             P
P_uM_1993_196     0.78571E+02    0.78571E+01             P
P_uM_1993_197     0.27143E+03    0.27143E+02             P
P_uM_1993_198     0.78571E+03    0.78571E+02             P
P_uM_1993_199     0.28571E+03    0.28571E+02             P
P_uM_1993_200     0.33571E+02    0.33571E+01             P
P_uM_1993_201     0.22143E+02    0.22143E+01             P
P_uM_1993_202     0.11429E+03    0.11429E+02             P
P_uM_1993_203     0.41429E+02    0.41429E+01             P
P_uM_1993_204     0.10000E+03    0.10000E+02             P
P_uM_1993_205     0.25714E+02    0.25714E+01             P
P_uM_1993_206     0.19286E+03    0.19286E+02             P
P_uM_1993_207     0.15000E+03    0.15000E+02             P
P_uM_1993_208     0.12857E+03    0.12857E+02             P
P_uM_1993_209     0.14286E+03    0.14286E+02             P
P_uM_1993_210     0.15000E+03    0.15000E+02             P
P_uM_1993_211     0.15000E+03    0.15000E+02             P
P_uM_1993_212     0.23571E+03    0.23571E+02             P
P_uM_1993_213     0.29286E+03    0.29286E+02             P
P_uM_1993_214     0.29286E+03    0.29286E+02             P
P_uM_1993_215     0.31429E+03    0.31429E+02             P
P_uM_1993_216     0.22857E+03    0.22857E+02             P
P_uM_1993_217     0.19286E+03    0.19286E+02             P
P_uM_1993_218     0.17857E+03    0.17857E+02             P
P_uM_1993_219     0.17143E+03    0.17143E+02             P
P_uM_1993_220     0.17857E+03    0.17857E+02             P
P_uM_1993_221     0.16429E+03    0.16429E+02             P
P_uM_1993_222     0.15000E+03    0.15000E+02             P
P_uM_1993_223     0.17143E+03    0.17143E+02             P
P_uM_1993_224     0.16429E+03    0.16429E+02             P
P_uM_1993_225     0.12143E+03    0.12143E+02             P
P_uM_1993_226     0.42143E+02    0.42143E+01             P
P_uM_1993_227     0.29286E+02    0.29286E+01             P

* model command line 
@PROJECT_DIR@\phast.bat

* model input/output 
@PROJECT_DIR@/@PHAST_ROOT_NAME@.chem.dat.tpl		@PHAST_ROOT_NAME@.chem.dat
@PROJECT_DIR@/@PHAST_ROOT_NAME@.trans.dat.tpl		@PHAST_ROOT_NAME@.trans.dat
P_uM_1993.ins		                		P_uM_1993.calc 

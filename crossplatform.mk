ifdef SystemRoot
FIXPATH = $(subst /,\,$1)
RM = -del /Q
RMF = -rd /Q /S
MD = -md
SENDNULL = 2> nul
SENDNULLALL = > nul 1> nul 2> nul
MV = copy
else
FIXPATH = $1
RM = rm -f
RMF = rm -rf
MD = mkdir -p
MV = mv
SENDNULL = 
SENDNULLALL = 
endif
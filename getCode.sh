
PREFIX="out/getCode"
CHECKPREFIX="$PREFIX/checks"
LOGFILE="$PREFIX/log.txt"
INDENTEDTEMPFILE="$PREFIX/tempIndented.txt"
TEMPFILE="$PREFIX/temp.txt"
INPUTFILE=$1
START=$2
END=$3

SANITIZEDINPUTFILE=`echo $INPUTFILE | tr '/\' "-"`
CHECKFILE="$CHECKPREFIX/$SANITIZEDINPUTFILE-$START-$END.txt"

# Make sure the output directory exists
mkdir -p $PREFIX
mkdir -p $CHECKPREFIX

# Empty the log file
echo "file:$INPUTFILE\nstart:$START\nend:$END" > $LOGFILE

# Check if the file exists, exit otherwise
if [[ ! -f "$INPUTFILE" ]]; then
  echo "$INPUTFILE does not exist!" >> $LOGFILE
  exit 1
fi

# Get the desired lines from the file and output to temporary file
sed -n "${START},${END}p;${END}q" $INPUTFILE > $INDENTEDTEMPFILE
# Remove excess indentation from file
awk 'NR==1 && match($0, /^ */) {p=RLENGTH+1}; {print(substr($0,p))}' $INDENTEDTEMPFILE > $TEMPFILE

HASH=`shasum -a 256 $TEMPFILE`
if [[ ! -f "$CHECKFILE" ]]; then
  echo "No check file found, creating one" >> $LOGFILE
  echo "$HASH" > $CHECKFILE
  exit 0
else
  echo "Previous check file found, checking for changes" >> $LOGFILE
  OLDHASH=`cat $CHECKFILE`
  if [[ "$OLDHASH" != "$HASH" ]]; then
    echo "Hashes do not match!" >> $LOGFILE
    echo "  Old: $OLDHASH" >> $LOGFILE
    echo "  New: $HASH" >> $LOGFILE
    rm "$TEMPFILE"
    exit 1
  else
    echo "Hashes match, exiting" >> $LOGFILE
    exit 0
  fi
fi


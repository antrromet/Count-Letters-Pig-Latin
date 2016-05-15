input_lines = LOAD 'in/' AS (line:chararray);

splits = FOREACH input_lines GENERATE STRSPLIT(LOWER(line),'') AS spl;
flatten_splits = FOREACH splits GENERATE FLATTEN(TOBAG(spl));
letters = FOREACH flatten_splits GENERATE FLATTEN(TOBAG(*)) AS letter;

-- storing into a file because http://stackoverflow.com/questions/17244001/cannot-cast-bytearray-to-chararray-in-pig
STORE letters into 'letters/';

-- loading from file so that the schema is present and is not NULL
letters = LOAD 'letters/part-m-00000' AS (letter:chararray);

letter_groups = GROUP letters BY letter;

letter_count = FOREACH letter_groups GENERATE group AS letter, COUNT(letters) AS count;
-- removing any junk values with 0 count
letter_count = FILTER letter_count BY count > 0;

ordered_letter_count = ORDER letter_count BY letter ASC;

DUMP ordered_letter_count;
STORE ordered_letter_count into 'charcount/';

input_lines = LOAD 'in/' AS (line:chararray);

splits = FOREACH input_lines GENERATE STRSPLIT(LOWER(line),'') AS spl;
flatten_splits = FOREACH splits GENERATE FLATTEN(TOBAG(spl));
letters = FOREACH flatten_splits GENERATE FLATTEN(TOBAG(*)) AS letter;

-- storing into a file because http://stackoverflow.com/questions/17244001/cannot-cast-bytearray-to-chararray-in-pig
STORE letters into 'letters/';

-- loading from file so that the schema is present and is not NULL
letters = LOAD 'letters/part-m-00000' AS (letter:chararray);
vovels = FILTER letters BY (letter == 'a' or letter == 'e' or letter == 'i' or letter == 'o' or letter == 'u');

vovel_groups = GROUP vovels BY letter;

vovel_count = FOREACH vovel_groups GENERATE group AS letter, COUNT(vovels) AS count;
-- removing any junk values with 0 count
vovel_count = FILTER vovel_count BY count > 0;

ordered_vovel_count = ORDER vovel_count BY letter ASC;

DUMP ordered_vovel_count;
STORE ordered_vovel_count into 'vovelcount/';

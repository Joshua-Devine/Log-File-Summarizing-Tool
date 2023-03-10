# Log File Summarizing Tool
Perl script used for summarizing structured and unstructured text log files for further analysis.  Each log file record must be a contained within a single line.  Multi-line records need to be normalized prior to processing with this tool.

## Usage
Process a sample log file using "log_summary.pl" and save the output for further analysis.  Very large log files may take a while to process. To reduce processing time, consider truncating the log file to a good representative sample.  This script has been used for up to 20GB of uncompressed log data. 

```cat ./sample_log | ./log_summary.pl > summarized.log```

"log_summary.pl" will summarize log files using the default pattern match of 73 percent similarity, which should work for most log types.  If the results are summarized too broadly for accurate analysis, the percent similar can be adjusted as a command line argument. 

```cat ./sample_log | ./log_summary.pl .85 > summarized.log```

In the example above, the script will only summarize logs that have an 85 percent similarity (don't forget the decimal!).  This will dramatically increase processing time, but will have a higher fidelity for further analysis.  If processing time is too long, or the log file analysis does not require a high fidelity, reduce the percentage below the default of 73.

## Tips and Tricks

1. For best results, remove redundant or low-information fields from the input log sample to improve the summary and increase readability. For example, remove time and date fields, redundant GUIDs, or standard pre-pended information that is not necessary to gain understanding of your sample log data.

If you are comfortable with regular expressions, uncomment lines 18 or 19 of the script and modify the reg-ex to remove unnecessary input data for analysis.

`18    #s/^!.*?>(.*$)/$1/; #Uncomment and modify regex to remove any unnecessary prepended strings for better analysis`

`19    #s/[A-Z][a-z]{2}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}\.*\d*\s+//g; #Uncomment and modify regex to remove timestamps for better analysis
`

2. When processing logs stored in gzip format, use gunzip's standard-out to pipe to "log_summary.pl", rather than decompressing on disk.  This saves disk space and overall processing time.

```gunzip -c ./sample_log.gz | ./log_summary.pl .80 > summarized.log```

3. After processing a sample log and saving the summary analysis to a file, you can start to review the data.  The output will display, in decending order, a representative log record with a count of similar records found.  This is essentially a long-tail analysis.

Review each entry, determine whether the log record contains valuable data, disposition accordingly, and continue analysis until complete.

This can be performed by many different methods, but here is a quick command line method for removing entries that have already been reviewed. Add the unique strings to the egrep statement to remove from your current analysis.

```cat ./summarized.log | egrep -v "event ID|another unique identifier|other" | less```

4. When higher fidelity is needed for specific types of log entries, use grep to match the records needed from the input sample log and pass to "log_summary.pl" with a higher percent threshold.

``` cat ./sample.log | grep "Event ID 12345" | ./log_summary.pl .90 > specific_event_analysis.log```




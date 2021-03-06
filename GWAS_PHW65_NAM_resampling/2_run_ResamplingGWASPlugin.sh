limit=1.0E-4 # Entry limit for adding SNPs to resampling model

for CHR in $( seq 10 ); do

    genoFile=../project_parental_SNPs/allPops_chr${CHR}_projected10M_TASSEL.txt
    importString="-fork1 -importGuess $genoFile"
    resampleString=""
    runForkString="-runfork1"
    
    for NUM in $( seq $( wc -l traits.txt | cut -f1 -d" " )); do
	
	TRAIT=$( head -$NUM traits.txt | tail -1 )
	NUMplusOne=$( expr $NUM + 1 ) # Because fork1 imports genotype data

	outBase=./results/${TRAIT}/resampling_${TRAIT}_chr${CHR}
	residFile=./results/${TRAIT}/stepwise_${TRAIT}_chr_${CHR}.txt


	# Construct import section of TASSEL command
	importString=$( echo $importString -fork${NUMplusOne} -r ${residFile} )
	# Construct portion of TASSEL command to merge datasets and run the plugin
	resampleString=$( echo $resampleString -combine -input1 -input${NUMplusOne} -intersect -ResamplingGWASPlugin -enterLimit $limit -endPlugin -export $outBase.txt)
	# Construct portion of TASSEL command to run each fork
	runForkString=$( echo $runForkString -runfork$NUMplusOne )
	
    done

    command="./TASSEL5/run_custom_pipeline.pl -Xms50g -Xmx100g -debug $importString $resampleString $runForkString"
    nohup $command &> results/resampling_chr${CHR}.log &

    # Only run half of the chromosomes at a time
    if [ $CHR = 5 ]
    then
	wait
    fi

done

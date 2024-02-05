
def set_chr(config, species):
    if species == "human":
        config["total_chromosomes"]=24
    if species == "mouse":
        config["total_chromosomes"]=21

    return config["total_chromosomes"]



# rule set_chr_species:
#     input: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/checks/check_species.ok", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
#     output: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/checks/set_species.ok", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
#     log: expand("{sctrip_dir}/breakpointR-pipeline/logs/check_species.log", sctrip_dir=SCTRIP_DIR)
#     run: set_chr(config, {input})



rule check_species:
    input: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    output: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/checks/check_species.ok", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/check_species.log", sctrip_dir=SCTRIP_DIR)
    conda: "alignmentenv"
    shell:
        """
        if samtools view -H {input}/*.bam | grep -Fq 'chr21'
        then
            echo "human" > {output}
        else
            echo "mouse" > {output}
        fi
        """



rule run_breakpointR:
    input: 
        bam_dir=expand("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam", sctrip_dir=SCTRIP_DIR, sample=SAMPLES),
    output: 
        out_dir=directory(expand("{sctrip_dir}/breakpointR-pipeline/{sample}/breakpointR_output", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)),
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{sample}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/run_breakpointR.log", sctrip_dir=SCTRIP_DIR)
    conda: "breakpointR"
    shell:
        """
        Rscript workflow/scripts/breakpointR_run/breakpointR_exec.R \
            {input.bam_dir} \
            {output.out_dir} \
            {config[pairedEndReads]} \
            {resources.threads} \
            {config[minReads]} \
            {config[maskRegions]} \
            {config[reuse_existing_files]} \
            {config[windowsize]} \
            {config[background]} \
            {config[binMethod]} \
            {config[pair2frgm]} \
            {config[min_mapq]} \
            {config[callHotSpots]} \
            {config[filtAlt]} \
            {config[total_chromosomes]}
        """



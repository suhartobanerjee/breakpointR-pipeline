#rule check_copy_selected_bams:
#    input: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam/labels.tsv", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
#    output: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/checks/check_copy_selected_bams.ok", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
#    shell:
#        """
#        workflow/scripts/select_bam/check_copy_selected_bams.sh {input} > {log} 2>&1
#        if [ $? -eq 0 ]; then
#            touch {output}
#        else
#            echo "bam files were not faithfully copied"
#            exit 1
#        fi
#        """

def get_selection_list(wildcards):
    if(config["manual_selection"] != ""):
        return config["manual_selection"]
    else:
        return wildcards.sctrip_dir + "/" + wildcards.sample + "/cell_selection/labels.tsv"


rule symlink_selected_bams:
    input: 
        cell_list=get_selection_list,
        bam_dir=expand("{sctrip_dir}/{{sample}}/bam", sctrip_dir=config["data_location"])
    output: 
        selected_bam=directory("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam"),
        labels_tsv="{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam/labels.tsv"
    shell: 
        "workflow/scripts/select_bam/symlink_selected_bams.sh {input.cell_list} {input.bam_dir} {output.selected_bam}"

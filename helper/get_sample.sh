RESULT=($(bcftools query -l $1))
echo -e ${RESULT[0]}\\ttumor
echo -e ${RESULT[1]}\\tcontrol

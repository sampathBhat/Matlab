% run this function to realise the turbo encoder
function[message_length,message]=final_lte_encoder
message_length=40;
message= input('enter the bits'); 
LTE_Turbo_encoder( message, message_length );
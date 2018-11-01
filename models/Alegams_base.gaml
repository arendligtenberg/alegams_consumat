/**
* 
*version may 2018
arend ligtenberg
* 
*/

model Alegams_base

import "./Alegams_globals.gaml"
import "./Alegams_plot.gaml"
import "./Alegams_farm.gaml"
import "./Alegams_statistics.gaml"

global{
		
	
	geometry shape <- envelope(plot_file);

	init{

	// create plot though GIS file
	
		create plot from: plot_file with: 	
		[
		plot_Id::int(read("OBJECTID")),
		tot_Area::(float(read("Shape_Area"))),
		LU_model::int(read("LU_model")),
		LU_local::int(read("LU_local")),
		LU_office::string(read("LU_Office")),
		LU_cad::string(read("LU_Cad1")),
		Int_motivat::int(read("In_motivat"))
			
		]{		}

	//create a farm on each plot with a shrimp farm
		ask plot{
			
			if self.production_System != 999{
					//write "Creating farmer";
					create farm number:1 {
						set farmPlot <- myself;
						set name <- "Schrimpfarmer_"+farmPlot.plot_Id;
						set farmPlot.name <- "plot of: "+name;
						location <- centroid(farmPlot);
					}		
				}
		}


		do calculate_averag_HH_account;
		do calculate_tot_areas;
		do calculate_num_plot;

	}//end init
	

	
	reflex output_Statistics{
		do calculate_averag_HH_account;
		do calculate_tot_areas;
		do calculate_num_plot;
		do calculate_yield;
		do export_spreadsheet;
		
		if time = 1{do export_maps;}
		if time = 20{do export_maps;}
		if time = 240 {do pause;}
		
	}
	
//		reflex climate_scenario_min when: time mod 12 = 0
//	{
//		farmPlotFailureRate_INT <- farmPlotFailureRate_INT + (farmPlotFailureRate_INT * 0.0);
//		farmPlotFailureRate_IE <- farmPlotFailureRate_IE + (farmPlotFailureRate_IE * 0.0015);
//		farmPlotFailureRate_IMS <- farmPlotFailureRate_IMS + (farmPlotFailureRate_IMS * 0.0);
//
//		crop_yield_INT_mono <- crop_yield_INT_mono - (crop_yield_INT_mono * 0.024);
//		crop_yield_INT_vana <- crop_yield_INT_vana - (crop_yield_INT_vana * 0.028);
//		crop_yield_IE <- crop_yield_IE - (crop_yield_IE * 0.024);
//		crop_yield_IMS <- crop_yield_IMS - (crop_yield_IMS * 0.017);
//	}
//		reflex climate_scenario_avg when: time mod 12 = 0
//	{
//		farmPlotFailureRate_INT <- farmPlotFailureRate_INT + (farmPlotFailureRate_INT * 0.0055);
//		farmPlotFailureRate_IE <- farmPlotFailureRate_IE + (farmPlotFailureRate_IE * 0.0083);
//		farmPlotFailureRate_IMS <- farmPlotFailureRate_IMS + (farmPlotFailureRate_IMS * 0.0059);
//
//		crop_yield_INT_mono <- crop_yield_INT_mono - (crop_yield_INT_mono * 0.024);
//		crop_yield_INT_vana <- crop_yield_INT_vana - (crop_yield_INT_vana * 0.028);
//		crop_yield_IE <- crop_yield_IE - (crop_yield_IE * 0.024);
//		crop_yield_IMS <- crop_yield_IMS - (crop_yield_IMS * 0.017);
//	}
//	}
//
		reflex climate_scenario_max when: time mod 12 = 0
	{
		farmPlotFailureRate_INT <- farmPlotFailureRate_INT + (farmPlotFailureRate_INT * 0.015);
		farmPlotFailureRate_IE <- farmPlotFailureRate_IE + (farmPlotFailureRate_IE * 0.019);
		farmPlotFailureRate_IMS <- farmPlotFailureRate_IMS + (farmPlotFailureRate_IMS * 0.01);

		crop_yield_INT_mono <- crop_yield_INT_mono - (crop_yield_INT_mono * 0.024);
		crop_yield_INT_vana <- crop_yield_INT_vana - (crop_yield_INT_vana * 0.028);
		crop_yield_IE <- crop_yield_IE - (crop_yield_IE * 0.024);
		crop_yield_IMS <- crop_yield_IMS - (crop_yield_IMS * 0.017);
	}



}
//Species section

//experiment section 
		
experiment alegams type: gui {
	parameter "Plot file" var: plot_file category: "GIS" ;

	output{
		display map_display {
			species plot aspect: base;
			species farm aspect: default;
		}
	
		display HH_Account {
			chart "Average saldo " type: series background: rgb ('white') size: {1,0.5} position: {0,0}{
		 	data "AVG Saldo" value: avg_HH_Account color: rgb ('red');
	 	 	
			}
		}
			
		display Area_of_prod_systems {
			chart "Areas of production systems " type: series background: rgb ('white') size: {1,0.5} position: {0,0}{
		 	data "Total Area INT" value: tot_INT color: rgb ('red');		
		 	data "Total Area IE" value: tot_IE color: rgb ('yellow');
		 	data "Total Area IMS" value: tot_IMS color: rgb ('green');
		 	data "Total Area Reduded" value: tot_reduced color: #black;
			}	
		}

		display Yields {
			chart "Total yield per production system " type: series background: rgb ('white') size: {1,0.5} position: {0,0}{
		 	data "Yield INT total" value: tot_Yield_INT color: rgb ('red');				
		 	data "Yield INT mono" value: tot_Yield_INT_mono color: rgb (255, 204, 204);
		 	data "Yield INT vana" value: tot_Yield_INT_vana color: rgb (255, 0, 102);
		 	data "Yield IE" value: tot_Yield_IE color: rgb ('yellow');
		 	data "yield IMS" value: tot_Yield_IMS color: rgb ('green');
			}	
		}
			
		display Number_of_prod_systems {
			chart "production_System " type: series background: rgb ('white') size: {1,0.5} position: {0,0}{
		 	//data "INT" value: plot count (each.color= # red) color: rgb ('red');
		 	data "INT" value: num_INT color: rgb ('red');
		 	data "IE" value: num_IE color: rgb ('yellow'); 	
		 	data "IMS" value: num_IMS color: rgb ('green'); 	
		 	data "INT_IE" value: num_INT_IE color: rgb ('sienna'); 	
		 	data "INT_IMS" value: num_INT_IMS color: rgb ('darkseagreen'); 	
			data "IE_IMS" value: num_IE_IMS color: rgb ('mediumaquamarine'); 
			//data "tot_S_Farmers" value: plot count(each.color!= # purple) color: rgb ('purple'); 	
			
			}	
		}
		
		
		monitor "Average saldo" value: avg_HH_Account;// refresh:every(1);
		monitor "STD dev saldo" value: std_HH_Account;// refresh:every(1);			
		monitor "Max saldo" value: max_HH_Account;// refresh:every(1);
		monitor "Min dev saldo" value: min_HH_Account;// refresh:every(1);		
		monitor "Total Area INT" value: tot_INT;// refresh:every(1);
		monitor "Total Area IE" value: tot_IE;// refresh:every(1);
		monitor "Total Area IMS" value: tot_IMS;// refresh:every(1);
		monitor "Total Area Reduced" value: tot_reduced;// refresh:every(1);
		monitor "Number of INT" value: num_INT;// refresh:every(1);
		monitor "Number of IE" value: num_IE;// refresh:every(1);
		monitor "Number of IMS" value: num_IMS;// refresh:every(1);
		monitor "Number of INT_IE" value: num_INT_IE;// refresh:every(1);
		monitor "Number of INT_IMS" value: num_INT_IMS;// refresh:every(1);
		monitor "failure rate INT" value: farmPlotFailureRate_INT;// refresh:every(1);
		monitor "failure rate IE" value: farmPlotFailureRate_IE;// refresh:every(1);
		monitor "failure rate IMS" value: farmPlotFailureRate_IMS;// refresh:every(1);
		monitor "Crop Yield Mono" value: crop_yield_INT_mono;// refresh:every(1);
		monitor "Crop Yield Vana" value: crop_yield_INT_vana;// refresh:every(1);
		monitor "Crop Yield IE" value: crop_yield_IE;// refresh:every(1);
		monitor "Crop Yield IMS" value: crop_yield_IMS;// refresh:every(1);
		
		

		

	}
}	



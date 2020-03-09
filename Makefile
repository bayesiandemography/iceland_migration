
LAST_YEAR_TRAIN = 2008
N_BURNIN = 15000
N_SIM = 15000
N_CHAIN = 4
N_THIN = 60
N_REPLICATE = 19
COVERAGE = 80
FORECAST_LENGTH = 20
SEED = 0

.PHONY: all
all: out/tab_priors_Baseline.tex \
     out/tab_performance.tex
     out/fig_direct_example.pdf \
     out/fig_population.pdf \
     out/fig_direct_region_age_sex.pdf \
     out/fig_direct_region_time.pdf \
     out/fig_direct_age_time.pdf \
     out/fig_replicate_data_Baseline.pdf \
     out/fig_replicate_data_Revised.pdf \
     out/fig_train_vs_full.pdf \
     out/fig_estimate_region_age.pdf \
     out/fig_forecast_region_age_Capital.pdf \
     out/fig_forecast_region_age_Westfjords.pdf


## Prepare data

out/levels_region.rds : src/levels_region.R
	Rscript $<

out/migration.rds : src/migration.R \
                    data/MAN01001.csv \
                    data/MAN01001-2.csv \
                    data/MAN01001-3.csv \
                    data/MAN01001-4.csv \
                    data/MAN01001-5.csv \
                    out/levels_region.rds
	Rscript $<

out/migration_train.rds : src/migration_train.R \
                          out/migration.rds
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/migration_test.rds : src/migration_test.R \
                         out/migration.rds
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/population.rds : src/population.R \
                     data/MAN02005.csv \
                     out/levels_region.rds
	Rscript $<

out/population_train.rds : src/population_train.R \
                           out/population.rds 
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/population_test.rds : src/population_test.R \
                          out/population.rds 
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/exposure.rds : src/exposure.R \
                   out/population.rds
	Rscript $<

out/exposure_train.rds : src/exposure_train.R \
                         out/exposure.rds
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/exposure_test.rds : src/exposure_test.R \
                        out/exposure.rds
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)


## Shared parameters

out/plot_theme.rds : src/plot_theme.R
	Rscript $<

out/param_example.rds : src/param_example.R
	Rscript $<

out/param_performance.rds : src/param_performance.R
	Rscript $<

out/param_forecast.rds : src/param_forecast.R
	Rscript $<

out/ylim_decomp.rds : src/ylim_decomp.R
	Rscript $<

out/conc_capital.rds : src/conc_capital.R \
                       out/population.rds
	Rscript $<

## Graphs of data and direct estimates

out/fig_direct_example.pdf : src/fig_direct_example.R \
                             out/migration_train.rds \
                             out/param_example.rds \
                             out/plot_theme.rds
	Rscript $<

out/fig_population.pdf : src/fig_population.R \
                         out/population_train.rds \
                         out/plot_theme.rds
	Rscript $<

out/fig_direct_region_age_sex.pdf : src/fig_direct_region_age_sex.R \
                                    out/migration_train.rds \
                                    out/exposure_train.rds \
                                    out/plot_theme.rds
	Rscript $<

out/fig_direct_region_time.pdf : src/fig_direct_region_time.R \
                                 out/migration_train.rds \
                                 out/exposure_train.rds \
                                 out/plot_theme.rds
	Rscript $<

out/vals_direct_age_time.rds : src/vals_direct_age_time.R \
                               out/migration_train.rds \
                               out/exposure_train.rds
	Rscript $<

out/fig_direct_age_time.pdf : src/fig_direct_age_time.R \
                              out/vals_direct_age_time.rds \
                              out/plot_theme.rds
	Rscript $<



## Construct models, and choose between them

out/covariates_region.rds : src/covariates_region.R \
                            out/population_train.rds 
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/covariates_region_age.rds : src/covariates_region_age.R \
                               out/population_train.rds 
	Rscript $< --last_year_train $(LAST_YEAR_TRAIN)

out/model_Baseline_train.est : src/model_Baseline.R \
                               out/migration_train.rds \
                               out/exposure_train.rds \
                               out/covariates_region.rds \
                               out/covariates_region_age.rds
	Rscript $< --dataset train \
                   --n_burnin $(N_BURNIN) \
                   --n_sim $(N_SIM) \
                   --n_chain $(N_CHAIN) \
                   --n_thin $(N_THIN) \
                   --seed $(SEED)

out/model_Revised_train.est : src/model_Revised.R \
                              out/migration_train.rds \
                              out/exposure_train.rds \
                              out/covariates_region.rds \
                              out/covariates_region_age.rds
	Rscript $< --dataset train \
                   --n_burnin $(N_BURNIN) \
                   --n_sim $(N_SIM) \
                   --n_chain $(N_CHAIN) \
                   --n_thin $(N_THIN) \
                   --seed $(SEED)

out/model_Baseline_train.pred : src/forecast_train.R \
                                out/model_Baseline_train.est \
                                out/exposure_test.rds
	Rscript $< --variant Baseline \
                   --seed $(SEED)

out/model_Revised_train.pred : src/forecast_train.R \
                               out/model_Revised_train.est \
                               out/exposure_test.rds
	Rscript $< --variant Revised \
                   --seed $(SEED)

out/vals_performance_Baseline.rds : src/vals_performance.R \
                                    out/model_Baseline_train.pred \
                                    out/param_performance.rds \
                                    out/migration_test.rds \
                                    out/exposure_test.rds \
                                    out/conc_capital.rds
	Rscript $< --variant Baseline

out/vals_performance_Revised.rds : src/vals_performance.R \
                                   out/model_Revised_train.pred \
                                   out/param_performance.rds \
                                   out/migration_test.rds \
                                   out/exposure_test.rds \
                                   out/conc_capital.rds
	Rscript $< --variant Revised

out/tab_performance.tex : src/tab_performance.R \
                          out/vals_performance_Baseline.rds \
                          out/vals_performance_Revised.rds \
                          out/param_performance.rds
	Rscript $<

out/vals_width_Baseline.rds : src/vals_width.R \
                              out/model_Baseline_train.pred \
                              out/exposure_test.rds \
                              out/param_performance.rds
	Rscript $< --variant Baseline

out/vals_width_Revised.rds : src/vals_width.R \
                             out/model_Revised_train.pred \
                             out/exposure_test.rds \
                             out/param_performance.rds
	Rscript $< --variant Revised

out/fig_width.pdf : src/fig_width.R \
                    out/vals_width_Baseline.rds \
                    out/vals_width_Revised.rds \
                    out/plot_theme.rds
	Rscript $<


## Replicate data

out/vals_replicate_data_Baseline.rds : src/vals_replicate_data.R \
                                       out/model_Baseline_train.est \
                                       out/migration_train.rds \
                                       out/exposure_train.rds
	Rscript $< --variant Baseline \
                   --n_replicate $(N_REPLICATE) \
                   --seed $(SEED)

out/vals_replicate_data_Revised.rds : src/vals_replicate_data.R \
                                      out/model_Revised_train.est \
                                      out/migration_train.rds \
                                      out/exposure_train.rds
	Rscript $< --variant Revised \
                   --n_replicate $(N_REPLICATE) \
                   --seed $(SEED)

out/ylim_replicate_data.rds : src/ylim_replicate_data.R \
                              out/vals_replicate_data_Baseline.rds \
                              out/vals_replicate_data_Revised.rds
	Rscript $<

out/fig_replicate_data_Baseline.pdf : src/fig_replicate_data.R \
                                      out/vals_replicate_data_Baseline.rds \
                                      out/ylim_replicate_data.rds \
                                      out/plot_theme.rds
	Rscript $< --variant Baseline \
                   --seed $(SEED)

out/fig_replicate_data_Revised.pdf : src/fig_replicate_data.R \
                                     out/vals_replicate_data_Revised.rds \
                                     out/ylim_replicate_data.rds \
                                     out/plot_theme.rds
	Rscript $< --variant Revised \
                   --seed $(SEED)



## Table of priors

out/tab_priors_Baseline.tex : src/tab_priors.R \
                              out/model_Baseline_train.est
	Rscript $< --variant Baseline

out/tab_priors_Revised.tex : src/tab_priors.R \
                             out/model_Revised_train.est
	Rscript $< --variant Revised


## Final estimation and forecast - using Revised model

out/model_Revised_full.est : src/model_Revised.R \
                              out/migration.rds \
                              out/exposure.rds \
                              out/covariates_region.rds \
                              out/covariates_region_age.rds
	Rscript $< --dataset full \
                   --n_burnin $(N_BURNIN) \
                   --n_sim $(N_SIM) \
                   --n_chain $(N_CHAIN) \
                   --n_thin $(N_THIN) \
                   --seed $(SEED)

out/model_Revised_full.pred : src/forecast_full.R \
                               out/model_Revised_full.est
	Rscript $< --variant Revised \
                   --forecast_length $(FORECAST_LENGTH) \
                   --seed $(SEED)

out/vals_train_vs_full.rds : src/vals_train_vs_full.R \
                             out/model_Revised_train.est \
                             out/model_Revised_full.est
	Rscript $< --variant Revised

out/fig_train_vs_full.pdf : src/fig_train_vs_full.R \
                            out/vals_train_vs_full.rds \
                            out/plot_theme.rds
	Rscript $<

out/vals_estimate_region_age.rds : src/vals_estimate_region_age.R \
                                   out/migration.rds \
                                   out/exposure.rds \
                                   out/model_Revised_full.pred \
                                   out/param_forecast.rds
	Rscript $< --variant Revised

out/fig_estimate_region_age.pdf : src/fig_estimate_region_age.R \
                                  out/vals_estimate_region_age.rds \
                                  out/plot_theme.rds
	Rscript $< --region Capital

out/vals_forecast_region_age_Capital.rds : src/vals_forecast_region_age.R \
                                           out/migration.rds \
                                           out/exposure.rds \
                                           out/model_Revised_full.est \
                                           out/model_Revised_full.pred \
                                           out/param_forecast.rds
	Rscript $< --variant Revised \
                   --region Capital

out/fig_forecast_region_age_Capital.pdf : src/fig_forecast_region_age.R \
                                          out/vals_forecast_region_age_Capital.rds \
                                          out/plot_theme.rds
	Rscript $< --region Capital

out/vals_forecast_region_age_Westfjords.rds : src/vals_forecast_region_age.R \
                                              out/migration.rds \
                                              out/exposure.rds \
                                              out/model_Revised_full.est \
                                              out/model_Revised_full.pred \
                                              out/param_forecast.rds
	Rscript $< --variant Revised \
                   --region Westfjords

out/fig_forecast_region_age_Westfjords.pdf : src/fig_forecast_region_age.R \
                                             out/vals_forecast_region_age_Westfjords.rds \
                                             out/plot_theme.rds
	Rscript $< --region Westfjords



## Clean up

.PHONY: clean
clean:
	rm -rf out
	mkdir -p out




CFG_TEE_TA_LOG_LEVEL ?= 4
CFG_TA_OPTEE_CORE_API_COMPAT_1_1=y

# The UUID for the Trusted Application
BINARY=a0be14df-62b5-429e-966d-866d47cedaec

-include $(TA_DEV_KIT_DIR)/mk/ta_dev_kit.mk

ifeq ($(wildcard $(TA_DEV_KIT_DIR)/mk/ta_dev_kit.mk), )
clean:
	rm -f *.o .*.o.d .*.o.cmd .*.ld.d *.dmp *.elf *.map *.ta *.lds dyn_list
	# @echo 'Note: $$(TA_DEV_KIT_DIR)/mk/ta_dev_kit.mk not found, cannot clean TA'
	# @echo 'Note: TA_DEV_KIT_DIR=$(TA_DEV_KIT_DIR)'
endif

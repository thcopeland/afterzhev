#include "avr.h"
#include "eeprom.h"

void avr_init_eeprom_state(struct avr_eeprom_state *eep) {
  eep->progress = 0;
  eep->addr = 0;
  eep->value = 0;
  eep->status = 0;
}

void avr_set_eeprom_reg(struct avr *avr, uint16_t addr, uint8_t val) {
  val &= AVR_ECCR_MASK;
  avr->mem[addr] = val;

  if (val & AVR_ECCR_EEMPE) {
    avr->eeprom_data.status = 4;
  }

  if ((val & AVR_ECCR_EEPE) && (avr->eeprom_data.status & 0x0f) > 0) {
    // write/erase EEPROM
    avr->eeprom_data.addr = avr->mem[avr->model.reg_eear];
    if (avr->model.eepsize > 255) {
      avr->eeprom_data.addr |= (avr->mem[avr->model.reg_eear+1] << 8);
    }
    avr->eeprom_data.addr &= avr->model.msk_eear;

    if (!(val & AVR_ECCR_EEPM0) && !(val & AVR_ECCR_EEPM1)) {
      // erase and write atomically
      avr->eeprom_data.progress = 54400;
      avr->eeprom_data.value = avr->mem[avr->model.reg_eedr];
    } else if ((val & AVR_ECCR_EEPM0) && !(val & AVR_ECCR_EEPM1)) {
      // erase only
      avr->eeprom_data.progress = 28800;
      avr->eeprom_data.value = 0;
    } else if (!(val & AVR_ECCR_EEPM0) && (val & AVR_ECCR_EEPM1)) {
      // write only
      avr->eeprom_data.progress = 28800;
      avr->eeprom_data.value = avr->mem[avr->model.reg_eedr];
    } else {
      // reserved
    }
  } else if ((val & AVR_ECCR_EERE) && (avr->eeprom_data.status & 0x0f)) {
    // read EEPROM (immediate)
    uint16_t addr = avr->mem[avr->model.reg_eear];
    if (avr->model.eepsize > 255) {
      addr |= (avr->mem[avr->model.reg_eear+1] << 8);
    }
    avr->mem[avr->model.reg_eedr] = avr->eep[addr];
  }
}

static void avr_write_complete(struct avr *avr) {
  avr->eep[avr->eeprom_data.addr] = avr->eeprom_data.value;
  avr->mem[avr->model.reg_eecr] &= ~AVR_ECCR_EEPE;
  if (avr->mem[avr->model.reg_eecr] & AVR_ECCR_EERIE) {
    avr->eeprom_data.status |= 0x10;
  }
}

void avr_update_eeprom(struct avr *avr) {
  if (avr->eeprom_data.status & 0x0f) {
    avr->eeprom_data.status--;
  }

  if (avr->eeprom_data.progress > 0) {
    avr->eeprom_data.progress--;
    if (avr->eeprom_data.progress == 0) {
      avr_write_complete(avr);
    }
  }
}
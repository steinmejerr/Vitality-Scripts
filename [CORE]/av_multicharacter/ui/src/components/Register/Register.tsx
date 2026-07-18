import '@mantine/dates/styles.css';
import { useEffect, useState } from 'react';
import { Flex, Select, Button, TextInput, Group } from "@mantine/core"
import { DatePickerInput } from '@mantine/dates';
import { useRecoilValue } from 'recoil';
import { CurrentCharacter, Lang, Settings } from '../../reducers/atoms';
import { formatBirthdate } from '../../hooks/formatBirthdate';
import classes from './style.module.css'
import { fetchNui } from '../../hooks/useNuiEvents';

interface Properties {
    setScreen: (name: string) => void;
    setTitle: (name: string) => void;
}

interface CharacterInfo {
  slot?: number;
  firstname?: string;
  lastname?: string;
  nationality?: string;
  birthdate?: Date;
  sex?: number;
}

export const Register = ({setScreen, setTitle}:Properties) => {
  const settings:any = useRecoilValue(Settings)
  const lang:any = useRecoilValue(Lang)
  const current = useRecoilValue(CurrentCharacter)
  const [loading, setLoading] = useState(false)
  const [character, setCharacter] = useState<CharacterInfo>({slot: current?.slot})
  const [canSave, setCanSave] = useState(false)

  const handleCancel = () => {
    setScreen("characters")
    setTitle(lang.title_character_selection)
  }

  const handleChange = (field:string, value:string) =>{
    setCharacter({...character, [field]: value == "" ? null : value})
  }

  const handleSave = async () => {
    setLoading(true)
    await fetchNui('av_multicharacter', 'register', character)
    setLoading(false)
  }

  useEffect(() => {
    const isComplete = !!character.firstname && !!character.lastname && !!character.birthdate && !!character.nationality && character.sex !== undefined; 
    setCanSave(isComplete);
  }, [character]);
  
  return <Flex direction="column" mt="md" gap="md">
    <TextInput label={lang.firstName} withAsterisk classNames={classes} onChange={(e)=>{handleChange("firstname", e.target.value)}} disabled={loading} maxLength={20}/>
    <TextInput label={lang.lastName} withAsterisk classNames={classes} onChange={(e)=>{handleChange("lastname", e.target.value)}} disabled={loading} maxLength={20}/>
    <TextInput label={lang.nationality} withAsterisk classNames={classes} onChange={(e)=>{handleChange("nationality", e.target.value)}} disabled={loading} maxLength={20}/>
    <Select label={lang.gender} data={settings.genders} withAsterisk allowDeselect={false} classNames={classes} onFocus={()=>{}} onChange={(e)=>{if(!e) return; handleChange("sex", e)}} disabled={loading}/>
    <DatePickerInput
      label={lang.birthdate}
      valueFormat="MM-DD-YYYY"
      allowDeselect={false}
      disabled={loading}
      maxDate={new Date(settings.max_year, 11, 31)}
      minDate={new Date(settings.min_year, 0, 1)}
      onChange={(e)=>{
        if(!e) return;
        const formatted = formatBirthdate(e)
        handleChange("birthdate", formatted)
      }}
      classNames={classes}
      styles={{
        levelsGroup: {
          color: "white"
        },
        calendarHeaderControl: {
          backgroundColor: "unset"
        },
        calendarHeaderLevel: {
          backgroundColor: "unset"
        },
        weekday: {
          color: "rgba(255,255,255,0.80)"
        },
        yearsListControl: {
          color: "rgba(255,255,255,0.80)"
        },
        monthsListControl: {
          color: "rgba(255,255,255,0.80)"
        },
      }}
    />
    <Group justify="space-between" mt="sm" grow>
        <Button className={classes.delete} autoContrast color="rgba(240, 62, 62, 0.55)" c="white" fw={500} lts={1} onClick={() => {handleCancel()
        }} disabled={loading}>{lang.button_cancel}</Button>
        <Button className={classes.select} autoContrast color="rgba(99, 230, 190, 0.55)" c="white" fw={500} lts={1} disabled={!canSave || loading} onClick={() => {handleSave()}}>{lang.button_continue}</Button>
    </Group>
  </Flex>
};

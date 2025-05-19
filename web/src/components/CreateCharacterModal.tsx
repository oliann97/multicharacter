import React from "react";
import { Button, Group, rem, Select, TextInput, Box } from "@mantine/core";
import { useForm } from "@mantine/form";
import { DatePickerInput } from "@mantine/dates";
import { IconCalendar, IconUser, IconFlag, IconGenderBigender } from "@tabler/icons-react";
import { fetchNui } from "../utils/fetchNui";

interface Props {
	handleCreate: () => void;
	id: number;
}

const CreateCharacterModal: React.FC<Props> = (props) => {
	const calendarIcon = (
		<IconCalendar style={{ width: rem(18), height: rem(18) }} stroke={1.5} color="#228be6" />
	);
	
	const userIcon = (
		<IconUser style={{ width: rem(18), height: rem(18) }} stroke={1.5} color="#228be6" />
	);
	
	const flagIcon = (
		<IconFlag style={{ width: rem(18), height: rem(18) }} stroke={1.5} color="#228be6" />
	);
	
	const genderIcon = (
		<IconGenderBigender style={{ width: rem(18), height: rem(18) }} stroke={1.5} color="#228be6" />
	);

	const form = useForm({
		initialValues: {
			firstName: "",
			lastName: "",
			nationality: "",
			gender: "",
			birthdate: new Date("2006-12-31"),
		},
	});

	const handleSubmit = async (values: {
		firstName: string;
		lastName: string;
		nationality: string;
		gender: string;
		birthdate: Date;
	}) => {
		const dateString = values.birthdate.toISOString().slice(0, 10);
		props.handleCreate();
		await fetchNui<string>(
			"createCharacter",
			{ cid: props.id, character: { ...values, birthdate: dateString } },
			{ data: "success" }
		);
	};

	return (
		<Box p="xs">
			<form onSubmit={form.onSubmit((values) => handleSubmit(values))}>
				<Group grow mb="md">
					<TextInput
						data-autofocus
						required
						placeholder='输入名字'
						label='名字'
						leftSection={userIcon}
						leftSectionPointerEvents='none'
						{...form.getInputProps("firstName")}
					/>

					<TextInput
						required
						placeholder='输入姓氏'
						label='姓氏'
						leftSection={userIcon}
						leftSectionPointerEvents='none'
						{...form.getInputProps("lastName")}
					/>
				</Group>

				<TextInput
					required
					placeholder='输入国籍'
					label='国籍'
					mb="md"
					leftSection={flagIcon}
					leftSectionPointerEvents='none'
					{...form.getInputProps("nationality")}
				/>

				<Select
					required
					label='性别'
					placeholder='选择性别'
					data={[
						{ value: 'Male', label: '男' },
						{ value: 'Female', label: '女' },
					]}
					defaultValue='Male'
					mb="md"
					leftSection={genderIcon}
					leftSectionPointerEvents='none'
					allowDeselect={false}
					{...form.getInputProps("gender")}
				/>

				<DatePickerInput
					leftSection={calendarIcon}
					leftSectionPointerEvents='none'
					label='出生日期'
					placeholder={"YYYY-MM-DD"}
					valueFormat='YYYY-MM-DD'
					defaultValue={new Date("2006-12-31")}
					minDate={new Date("1900-01-01")}
					maxDate={new Date("2006-12-31")}
					mb="lg"
					{...form.getInputProps("birthdate")}
				/>

				<Group justify='flex-end' mt='xl'>
					<Button color='green' variant='light' type='submit' size="md">
						创建角色
					</Button>
				</Group>
			</form>
		</Box>
	);
};

export default CreateCharacterModal;

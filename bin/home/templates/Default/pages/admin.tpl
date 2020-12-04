<_include=all title="Электронная очередь - Для администратора">

	<_Queue>

		<_current>
			<p>Текущий пациент %name%</p>
			<_finish auto>Закончить приём</_finish>
			<_delete auto>Отменить приём</_delete>
		</_current>

		<_current !>
			<_next>
				<p>Следующий пациент %name%</p>
				<_start auto>Начать приём</_start>
				<_delete auto>Отменить приём</_delete>
			</_next>

			<_next !>Пациенты закончились</_next>
		</_current>

	</_Queue>

</_include>
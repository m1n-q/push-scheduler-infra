class Parser:
    @classmethod
    def list_to_comma(cls, l: list[int]):
        return ",".join(list(map(str, l)))

    @classmethod
    def comma_to_list(cls, s: str):
        return list(map(int, s.split(',')))

    @classmethod
    def is_daily(cls, day_of_week, day_of_month):
        return day_of_week == '?' and day_of_month == '*'

    @classmethod
    def is_weekly(cls, day_of_week, day_of_month):
        return day_of_week != '*' and day_of_month == '?'

    @classmethod
    def is_monthly(cls, day_of_week, day_of_month):
        return day_of_month not in ['*', '?']

    @classmethod
    def get_routine_type(cls, day_of_week, day_of_month):
        if cls.is_monthly(day_of_week, day_of_month): return "MONTHLY"
        elif cls.is_weekly(day_of_week, day_of_month): return "WEEKLY"
        elif cls.is_daily(day_of_week, day_of_month): return "DAILY"
        else: raise NotImplementedError

    @classmethod
    def get_days(cls, routine_type, day_of_week, day_of_month):
        if routine_type == "WEEKLY": days = cls.comma_to_list(day_of_week)
        elif routine_type == "MONTHLY": days = cls.comma_to_list(day_of_month)
        else: days = []
        return days

    @classmethod
    def parse_expr(cls, expr):
        pos = expr.find('(')
        schedule_type = expr[:pos] # should be cron
        value = expr[pos + 1:-1]

        minute, hour, day_of_month, month, day_of_week, year = value.split()
        routine_type = cls.get_routine_type(day_of_week, day_of_month)
        days = cls.get_days(routine_type, day_of_week, day_of_month)
        return {'routine_type': routine_type, 'days': days, 'time': f'{hour}:{minute}'}

    @classmethod
    def to_expr(cls, routine_type, days, hour, minute):
        if routine_type == 'MONTHLY':
            day_of_week, day_of_month = '?', cls.list_to_comma(days)
        elif routine_type == 'WEEKLY':
            day_of_week, day_of_month = cls.list_to_comma(days), '?'
        else:
            day_of_week, day_of_month = '?', '*'

        return f'cron({minute} {hour} {day_of_month} * {day_of_week} *)'
